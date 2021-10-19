//
//  HomeModel.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import Combine
import SentinelWallet

private struct Constants {
    let timeout: TimeInterval = 5
    let limit: UInt64 = 20
}

private let constants = Constants()

enum HomeModelEvent {
    case error(Error)

    case showLoadingNodes(state: Bool)
    case showLoadingSubscriptions(state: Bool)

    case allLoaded
    
    case update(locations: [Node])
    case append(subscribedNode: Node)
    case reloadSubscriptions

    case connect

    case select(servers: [DNSServerType])
}

final class HomeModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager
    private let context: Context

    private let eventSubject = PassthroughSubject<HomeModelEvent, Never>()
    var eventPublisher: AnyPublisher<HomeModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var subscriptions: [SentinelWallet.Subscription] = []
    private var offset: UInt64 = 0
    private var reloadOnNextAppear = false

    init(context: Context) {
        self.context = context

        loadSubscriptions()
        fetchWalletInfo()

        eventSubject.send(.select(servers: context.dnsServersStorage.selectedDNS()))
    }

    // TODO: @Tori get from database
    func loadNodes() {
        eventSubject.send(.showLoadingNodes(state: true))

        context.sentinelService.queryNodes(
            offset: offset,
            limit: constants.limit,
            timeout: constants.timeout
        ) { [weak self] result in
            guard let self = self else { return }
            self.eventSubject.send(.showLoadingNodes(state: false))

            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let nodes):
                guard !nodes.isEmpty else {
                    self.eventSubject.send(.allLoaded)
                    return
                }
                self.offset += UInt64(nodes.count)
                self.eventSubject.send(.update(locations: nodes))
            }
        }
    }

    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
        eventSubject.send(.connect)
    }

    func isSubscribed(to node: String) -> Bool {
        subscriptions.contains(where: { $0.node == node })
    }

    func connectIfNeeded() {
        if context.connectionInfoStorage.shouldConnect() {
            eventSubject.send(.connect)
            reloadOnNextAppear = true
        }

        if reloadOnNextAppear {
            eventSubject.send(.reloadSubscriptions)
            loadSubscriptions()
            reloadOnNextAppear = false
        }
    }

    func disconnect() {
        context.tunnelManager.startDeactivationOfActiveTunnel()
    }
}

// MARK: - Private Methods

extension HomeModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }

    private func loadSubscriptions() {
        eventSubject.send(.showLoadingSubscriptions(state: true))
        context.sentinelService.fetchSubscriptions { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let subscriptions):
                self.subscriptions = subscriptions
                guard !subscriptions.isEmpty else {
                    self.eventSubject.send(.showLoadingSubscriptions(state: false))
                    return
                }
                self.loadNodes(from: Set(subscriptions.map { $0.node }))
            }
        }
    }

    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { error in
            log.error(error)
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
    
    private func loadNodes(from addresses: Set<String>) {
        addresses.enumerated().forEach { index, address in
            context.sentinelService.queryNodeStatus(address: address, timeout: constants.timeout) { [weak self] result in
                if index == addresses.count - 1 {
                    self?.eventSubject.send(.showLoadingSubscriptions(state: false))
                }
                switch result {
                case .failure(let error):
                    log.error(error)
                case .success(let node):
                    self?.eventSubject.send(.append(subscribedNode: node))
                }
            }
        }
    }
}
