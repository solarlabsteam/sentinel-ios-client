import Foundation
import Combine
import SentinelWallet
import GRPC

private struct Constants {
    let timeout: TimeInterval = 15
    let denom = "udvpn"
}

private let constants = Constants()

enum ConnectionModelEvent {
    case error(Error)
    case warning(Error)

    case setButton(isLoading: Bool)

    case update(isTunelActive: Bool)
    case updateConnection(status: ConnectionStatus)
    case updateLocation(countryName: String, moniker: String)
    case updateSubscription(initialBandwidth: String, bandwidthConsumed: String)
    case updateBandwidth(bandwidth: Bandwidth)
    case updateDuration(durationInSeconds: Int64)
    
    /// When the quota is over
    case openPlans(for: DVPNNodeInfo)
    case nodeIsNotAvailable
}

final class ConnectionModel {
    typealias Context = HasSentinelService & HasWalletService & HasStorage & HasTunnelManager
        & HasNetworkService
    
    private let context: Context

    private var isTunnelActive: Bool {
        context.tunnelManager.isTunnelActive
    }

    private var subscription: SentinelWallet.Subscription?

    private let eventSubject = PassthroughSubject<ConnectionModelEvent, Never>()
    var eventPublisher: AnyPublisher<ConnectionModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
        context.tunnelManager.delegate = self

        fetchWalletInfo()
    }
}

extension ConnectionModel {
    /// Refreshes subscriptions. Should be called each time when the app leaves the background state.
    func refreshNodeState() {
        guard subscription != nil else {
            return
        }
        refreshSubscriptions()
    }
    
    /// Should be called each time when the view appears
    func checkNodeForUpdate() {
        guard let address = context.storage.lastSelectedNode(), context.storage.shouldConnect() else {
            return
        }
        
        context.storage.set(shouldConnect: false)

        eventSubject.send(.setButton(isLoading: true))

        context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .failure(let error):
                self.show(error: error)
            case .success(let node):
                guard node.info.address != self.subscription?.node else { return }
                self.eventSubject.send(.setButton(isLoading: true))
                self.loadSubscriptions(selectedAddress: node.info.address, reconnect: true)
                self.context.storage.set(lastSelectedNode: node.info.address)
            }
        }
    }
    
    /// Should be called each time when we turn toggle to "on" state
    func connect() {
        guard let subscription = subscription else {
            eventSubject.send(.nodeIsNotAvailable)
            return
        }
        eventSubject.send(.setButton(isLoading: true))
        
        detectConnectionAndHandle(considerStatus: false, reconnect: true, subscription: subscription)
    }
    
    /// Should be called each time when we turn toggle to "off" state
    func disconnect() {
        guard let tunnel = context.tunnelManager.lastTunnel, tunnel.status != .disconnected else {
            fetchIP()
            return
        }

        eventSubject.send(.setButton(isLoading: true))
        context.tunnelManager.startDeactivation(of: tunnel)
    }
}

// MARK: - Subscriprion

extension ConnectionModel {
    private func refreshSubscriptions() {
        eventSubject.send(.setButton(isLoading: true))

        loadSubscriptions(selectedAddress: context.storage.lastSelectedNode())
    }

    private func loadSubscriptions(selectedAddress: String? = nil, reconnect: Bool = false) {
        context.sentinelService.fetchSubscriptions { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.show(error: error)

            case .success(let subscriptions):
                guard let selectedAddress = selectedAddress,
                      let subscription = subscriptions.last(where: { $0.node == selectedAddress}) else {
                    self.subscription = subscriptions.sorted(by: { $0.id > $1.id }).first
                    self.handleConnection(reconnect: reconnect)
                    return
                }

                self.subscription = subscription
                self.handleConnection(reconnect: reconnect)
            }
        }
    }

    private func handleConnection(reconnect: Bool) {
        guard let subscription = subscription else {
            if context.tunnelManager.startDeactivationOfActiveTunnel() != true {
                stopLoading()
                fetchIP()
                eventSubject.send(.updateLocation(countryName: L10n.Connection.LocationSelector.select, moniker: ""))
            }
            return
        }
        
        detectConnectionAndHandle(reconnect: reconnect, subscription: subscription)
    }

    private func update(subscriptionInfo: SentinelWallet.Subscription, status: ConnectionStatus) {
        eventSubject.send(.updateConnection(status: .subscriptionStatus))
        context.sentinelService.queryQuota(subscriptionID: subscriptionInfo.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.show(error: error)

            case .success(let quota):
                self.update(quota: quota, for: subscriptionInfo)
                self.stopLoading()
            }
        }

        updateLocation(address: subscriptionInfo.node, id: subscriptionInfo.id)
    }

    private func connect(to subscription: SentinelWallet.Subscription) {
        eventSubject.send(.updateConnection(status: .subscriptionStatus))
        context.sentinelService.queryQuota(subscriptionID: subscription.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.show(error: error)

            case .success(let quota):
                self.update(quota: quota, for: subscription)
                self.eventSubject.send(.updateConnection(status: .nodeStatus))
                self.context.sentinelService.queryNodeStatus(
                    address: subscription.node,
                    timeout: constants.timeout
                ) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        self?.show(error: error)
                    case .success(let node):
                        self?.createNewSession(subscription: subscription, nodeURL: node.remoteURL)
                    }
                }
            }
        }
    }
    
    // TODO: delete subscription?
    private func update(quota: Quota, for subscription: SentinelWallet.Subscription) {
        let initialBandwidth = quota.allocated
        let bandwidthConsumed = quota.consumed
        
        self.eventSubject.send(
            .updateSubscription(
                initialBandwidth: initialBandwidth,
                bandwidthConsumed: bandwidthConsumed
            )
        )

        fetchIP()
    }

    private func updateLocation(address: String, id: UInt64) {
        context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] response in
            switch response {
            case .failure(let error):
                guard self?.subscription != nil else {
                    return
                }
                log.error(error)
                self?.show(error: ConnectionModelError.nodeIsOffline)
            case .success(let node):
                self?.eventSubject.send(
                    .updateLocation(countryName: node.info.location.country, moniker: node.info.moniker)
                )
                self?.eventSubject.send(
                    .updateBandwidth(bandwidth: node.info.bandwidth)
                )
            }
        }
    }

    private func createNewSession(subscription: SentinelWallet.Subscription, nodeURL: String) {
        eventSubject.send(.updateConnection(status: .balanceCheck))
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.debug("Failed to fetch a balance due to \(error). Try to start a session anyway.")
                self.startSession(on: subscription, nodeURL: nodeURL)

            case .success(let balances):
                guard balances
                        .contains(
                            where: { $0.denom == constants.denom && Int($0.amount)! >= self.context.walletService.fee }
                        ) else {
                    self.eventSubject.send(.warning(ConnectionModelError.notEnoughTokens))
                    self.stopLoading()
                    return
                }
                self.startSession(on: subscription, nodeURL: nodeURL)
            }
        }
    }

    private func startSession(on subscription: SentinelWallet.Subscription, nodeURL: String) {
        eventSubject.send(.updateConnection(status: .sessionBroadcast))
        context.sentinelService.startNewSession(on: subscription) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.show(error: error)

            case .success(let id):
                self?.fetchConnectionData(remoteURLString: nodeURL, id: id)
            }
        }
    }
    
    private func detectConnectionAndHandle(
        considerStatus: Bool = true,
        reconnect: Bool,
        subscription: SentinelWallet.Subscription
    ) {
        detectConnection { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
                if reconnect {
                    self.connect(to: subscription)
                }
                
            case let .success((isTunnelActive, isSessionActive)):
                switch (isTunnelActive, isSessionActive) {
                case (true, true):
                    self.update(subscriptionInfo: subscription, status: .connected)
                case (false, true):
                    if let tunnel = self.context.tunnelManager.lastTunnel {
                        self.context.tunnelManager.startActivation(of: tunnel)
                        self.update(subscriptionInfo: subscription, status: .connected)
                    }
                case (true, false), (false, false):
                    self.connect(to: subscription)
                    self.updateLocation(address: subscription.node, id: subscription.id)
                }
            }
        }
    }
    
    /// Checks if tunnel and session are active
    private func detectConnection(
        considerStatus: Bool = true,
        completion: @escaping (Result<(Bool, Bool), Error>) -> Void
    ) {
        eventSubject.send(.updateConnection(status: .sessionStatus))
        
        var isTunnelActive: Bool

        if let tunnel = context.tunnelManager.lastTunnel {
            isTunnelActive = true
            
            if considerStatus {
                isTunnelActive = tunnel.status == .connected || tunnel.status == .connecting
            }
        } else {
            isTunnelActive = false
        }
        
        context.sentinelService.loadActiveSession { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let session):
                self.eventSubject.send(.updateDuration(durationInSeconds: session.durationInSeconds))
                
                guard let id = self.context.storage.lastSessionId(),
                        session.id == id else {
                    completion(.success((isTunnelActive, false)))
                    return
                }

                completion(.success((isTunnelActive, true)))
            }
        }
    }
}

// MARK: - Events

extension ConnectionModel {
    private func stopLoading() {
        eventSubject.send(.updateConnection(status: .init(from: isTunnelActive)))
        eventSubject.send(.setButton(isLoading: false))
    }

    private func show(error: Error) {
        log.error(error)
        stopLoading()
        eventSubject.send(.error(error))

        if !Connectivity.isConnectedToInternet() {
            eventSubject.send(.update(isTunelActive: isTunnelActive))
        }
    }
}

// MARK: - Network and Wallet work

extension ConnectionModel {
    private func fetchConnectionData(remoteURLString: String, id: UInt64) {
        eventSubject.send(.updateConnection(status: .keysExchange))

        var int = id.bigEndian
        let sessionIdData = Data(bytes: &int, count: 8)

        guard let signature = context.walletService.generateSignature(for: sessionIdData) else {
            show(error: ConnectionModelError.signatureGenerationFailed)
            return
        }

        context.networkService.fetchConnectionData(
            remoteURLString: remoteURLString,
            id: id,
            accountAddress: context.walletService.accountAddress,
            signature: signature
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                self.show(error: error)
            case let .success((data, wgKey)):
                self.context.storage.set(sessionId: Int(id))
                self.context.tunnelManager.createNewProfile(
                    from: data,
                    with: wgKey
                )
            }
        }
    }

    private func updateIP() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.fetchIP(stopLoading: true)
        }
    }

    private func fetchIP(stopLoading: Bool = false) {
        context.networkService.fetchIP() { [weak self] ipAddress in
            guard let self = self else { return }

            self.eventSubject.send(.update(isTunelActive: self.isTunnelActive))

            if stopLoading {
                self.stopLoading()
            }
        }
    }
    
    // MARK: - Wallet
    
    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { [weak self] error in
            if let error = error {
                if let statusError = error as? GRPC.GRPCStatus, statusError.code == .notFound {
                    return
                }
                self?.show(error: error)
            }
        }

        context.walletService.fetchTendermintNodeInfo { [weak self] result in
            switch result {
            case .success(let info):
                log.debug(info)
            case .failure(let error):
                self?.show(error: error)
            }
        }
    }
}

// MARK: - TunnelManagerDelegate

extension ConnectionModel: TunnelManagerDelegate {
    func handleTunnelUpdatingStatus() {
        eventSubject.send(.updateConnection(status: .tunnelUpdating))
    }

    func handleError(_ error: Error) {
        show(error: error)
    }

    func handleTunnelReconnection() {
        fetchIP(stopLoading: true)
    }
    
    func handleTunnelServiceCreation() {
        refreshSubscriptions()
    }
}

// MARK: - TunnelsServiceStatusDelegate

extension ConnectionModel: TunnelsServiceStatusDelegate {
    func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        show(error: error)
    }

    func activationAttemptSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully attempted activation")
    }

    func activationFailed(for tunnel: TunnelContainer, with error: TunnelActivationError) {
        show(error: error)
    }

    func activationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully activated")

        updateIP()
    }

    func deactivationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully deactivated")

        updateIP()
    }
}
