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

    case update(isTunnelActive: Bool)
    case updateConnection(status: ConnectionStatus)
    case updateLocation(countryName: String, moniker: String)
    case updateSubscription(initialBandwidth: String, bandwidthConsumed: String)
    case updateBandwidth(bandwidth: Bandwidth)
    case updateDuration(durationInSeconds: Int64)

    #warning("TODO @Tori sent this event if no quota is left on connect() call")
    /// When the quota is over
    case openPlans(for: DVPNNodeInfo)
}

final class ConnectionModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage & HasTunnelManager
        & HasNetworkService & HasNodesService
    
    private let context: Context

    private var isTunnelActive: Bool {
        context.tunnelManager.isTunnelActive
    }

    private var subscription: SentinelWallet.Subscription?

    private let eventSubject = PassthroughSubject<ConnectionModelEvent, Never>()
    var eventPublisher: AnyPublisher<ConnectionModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var selectedNode: DVPNNodeInfo?

    init(context: Context) {
        self.context = context
        context.tunnelManager.delegate = self

        fetchWalletInfo()
    }
}

extension ConnectionModel {
    func setInitNodeInfo() {
        guard let node = context.nodesService.nodes
                .first(where: { $0.address == context.connectionInfoStorage.lastSelectedNode() }) else {
                    return
                }
        
        selectedNode = node.node?.info
        
        eventSubject.send(.updateLocation(
            countryName: node.node!.info.location.country,
            moniker: node.node!.info.moniker)
        )
        
        eventSubject.send(.updateBandwidth(bandwidth: node.node!.info.bandwidth))
    }
    
    /// Refreshes subscriptions. Should be called each time when the app leaves the background state.
    func refreshNodeState() {
        guard subscription != nil else {
            return
        }
        refreshSubscriptions()
    }
    
    /// Should be called each time when the view appears
    func checkNodeForUpdate() {
        guard let address = context.connectionInfoStorage.lastSelectedNode(),
              context.connectionInfoStorage.shouldConnect() else {
            return
        }
        
        context.connectionInfoStorage.set(shouldConnect: false)

        eventSubject.send(.setButton(isLoading: true))

        context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .failure(let error):
                self.show(error: error)
            case .success(let node):
                self.eventSubject.send(.setButton(isLoading: true))
                self.loadSubscriptions(selectedAddress: node.node!.info.address, reconnect: true)
                self.context.connectionInfoStorage.set(lastSelectedNode: node.node!.info.address)
            }
        }
    }
    
    /// Should be called each time when we turn toggle to "on" state
    func connect() {
        guard let subscription = subscription else {
            eventSubject.send(.warning(ConnectionModelError.nodeIsOffline))
            return
        }
        eventSubject.send(.setButton(isLoading: true))
        
        detectConnectionAndHandle(considerStatus: false, reconnect: true, subscription: subscription)
    }
    
    /// Should be called each time when we turn toggle to "off" state
    func disconnect() {
        guard let tunnel = context.tunnelManager.lastTunnel, tunnel.status != .disconnected else {
            setTunnelActivity()
            return
        }

        eventSubject.send(.setButton(isLoading: true))
        context.tunnelManager.startDeactivation(of: tunnel)
    }
}

// MARK: - Subscriprion

extension ConnectionModel {
    private func checkQuotaAndSubscription(hasQuota: Bool) {
        guard hasQuota, subscription?.isActive ?? false else {
            guard let selectedNode = selectedNode else {
                return
            }
            eventSubject.send(.openPlans(for: selectedNode))
            return
        }
    }
    
    private func refreshSubscriptions() {
        eventSubject.send(.setButton(isLoading: true))

        loadSubscriptions(selectedAddress: context.connectionInfoStorage.lastSelectedNode())
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
                setTunnelActivity()
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
                self.update(quota: quota)
                self.setTunnelActivity()
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

            case let .success(quota):
                self.update(quota: quota)
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
    
    private func update(quota: Quota) {
        let initialBandwidth = quota.allocated
        let bandwidthConsumed = quota.consumed
        
        self.eventSubject.send(
            .updateSubscription(
                initialBandwidth: initialBandwidth,
                bandwidthConsumed: bandwidthConsumed
            )
        )
        
        let bandwidthLeft = (Int64(initialBandwidth) ?? 0) - (Int64(bandwidthConsumed) ?? 0)
        
        checkQuotaAndSubscription(hasQuota: bandwidthLeft != 0)
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
                self?.selectedNode = node.node?.info
                self?.eventSubject.send(
                    .updateLocation(countryName: node.node!.info.location.country,
                                    moniker: node.node!.info.moniker)
                )
                self?.eventSubject.send(
                    .updateBandwidth(bandwidth: node.node!.info.bandwidth)
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
                
                guard let id = self.context.connectionInfoStorage.lastSessionId(),
                      session.id == id,
                      let node = self.context.connectionInfoStorage.lastSelectedNode(),
                      session.node == node else {
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
        eventSubject.send(.update(isTunnelActive: isTunnelActive))
        eventSubject.send(.error(error))
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
                self.context.connectionInfoStorage.set(sessionId: Int(id))
                self.context.tunnelManager.createNewProfile(
                    from: data,
                    with: wgKey
                )
            }
        }
    }

    private func updateTunnelActivity() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.setTunnelActivity(stopLoading: true)
        }
    }

    private func setTunnelActivity(stopLoading: Bool = false) {
        eventSubject.send(.update(isTunnelActive: self.isTunnelActive))
        
        if stopLoading {
            self.stopLoading()
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
        setTunnelActivity(stopLoading: true)
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

        updateTunnelActivity()
    }

    func deactivationSucceeded(for tunnel: TunnelContainer) {
        log.debug("\(tunnel.name) is succesfully deactivated")

        updateTunnelActivity()
    }
}
