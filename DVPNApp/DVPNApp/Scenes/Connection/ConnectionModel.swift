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

    case openPlans(for: DVPNNodeInfo)
    case openNodes
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

    func refreshNodeState() {
        guard subscription != nil else {
            return
        }
        refreshSubscriptions()
    }

    #warning("TODO @Tori")
    // this one is called on screen opening after node selection and it will always reset sessionId even is node was not changged
    // flow need to be reworked, shouldConnect need to only toggle the connection

    func checkNodeForUpdate() {
        guard let address = context.storage.lastSelectedNode(),
              address != subscription?.node || context.storage.shouldConnect() else {
            return
        }

        context.storage.set(sessionId: nil)
        context.storage.set(shouldConnect: false)

        eventSubject.send(.setButton(isLoading: true))

        context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] response in
            switch response {
            case .failure(let error):
                self?.show(error: error)
            case .success(let node):
                self?.change(to: node.info)
            }
        }
    }

    #warning("TODO @Tori")
    // this one should now be called on screen opening and is context.storage.shouldConnect() is set
    // it now mean we need to connect to the node

    func change(to node: DVPNNodeInfo) {
        guard node.address != subscription?.node else { return }
        context.storage.set(sessionId: nil)
        eventSubject.send(.setButton(isLoading: true))
        loadSubscriptions(selectedAddress: node.address, reconnect: true)
        context.storage.set(lastSelectedNode: node.address)
    }

    func connect() {
        guard let subscription = subscription else {
            eventSubject.send(.openNodes)
            return
        }
        eventSubject.send(.setButton(isLoading: true))
        detectConnection(considerStatus: false) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
                self.connect(to: subscription)
            case .success(let isConnected):
                guard isConnected, let tunnel = self.context.tunnelManager.lastTunnel else {
                    self.connect(to: subscription)
                    return
                }
                self.context.tunnelManager.startActivation(of: tunnel)
            }
        }
    }

    func disconnect() {
        guard let tunnel = context.tunnelManager.lastTunnel, tunnel.status != .disconnected else {
            fetchIP()
            return
        }

        eventSubject.send(.setButton(isLoading: true))
        context.tunnelManager.startDeactivation(of: tunnel)
    }
}

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

        detectConnection { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.show(error: error)
            case .success(let isConnected):
                guard reconnect else {
                    self.update(subscriptionInfo: subscription, status: .init(from: isConnected))
                    return
                }
                self.connect(to: subscription)
                self.updateLocation(address: subscription.node, id: subscription.id)
            }
        }
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

    private func detectConnection(considerStatus: Bool = true, completion: @escaping (Result<Bool, Error>) -> Void) {
        eventSubject.send(.updateConnection(status: .sessionStatus))

        guard let tunnel = context.tunnelManager.lastTunnel, let id = context.storage.lastSessionId() else {
            completion(.success(false))
            return
        }

        if considerStatus {
            guard tunnel.status == .connected || tunnel.status == .connecting else {
                completion(.success(false))
                return
            }
        }
        
        context.sentinelService.loadActiveSession { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let session):
                // TODO: @tori Fix duration - it's always zero for now
                print("session: ", session.id, "duration: ", session.durationInSeconds)
                
                guard session.id == id else {
                    completion(.success(false))
                    return
                }

                completion(.success(true))
            }
        }
    }
}

// MARK: - Private

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
