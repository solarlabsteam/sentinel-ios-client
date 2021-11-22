//
//  SubscribedNodesModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import Foundation
import Combine
import SentinelWallet

enum SubscriptionsState {
    case empty
    case noConnection
    
    var title: String {
        switch self {
        case .empty:
            return L10n.SubscribedNodes.notFound
        case .noConnection:
            return L10n.SubscribedNodes.noConnection
        }
    }
}

enum SubscribedNodesModelEvent {
    case error(Error)
    
    case showLoadingSubscriptions(state: Bool)
    
    case update(locations: [SentinelNode])
    case set(subscribedNodes: [SentinelNode])
    case setSubscriptionsState(SubscriptionsState)
    case reloadSubscriptions
}

final class SubscribedNodesModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<SubscribedNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<SubscribedNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var subscriptions: [SentinelWallet.Subscription] = []
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.context = context

        loadSubscriptions()
        fetchWalletInfo()
        
        context.nodesService.loadAllNodesIfNeeded { result in
            if case let .success(nodes) = result {
                context.nodesService.loadNodesInfo(for: nodes)
            }
        }
    }
    
    func subscribeToEvents() {
        context.nodesService.isLoadingSubscriptions
            .map { .showLoadingSubscriptions(state: $0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
        
        context.nodesService.subscribedNodes
            .map { .set(subscribedNodes: $0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }

    func setNodes() {
        eventSubject.send(.update(locations: context.nodesService.nodes))
    }

    func isSubscribed(to node: String) -> Bool {
        subscriptions.contains(where: { $0.node == node })
    }
}

// MARK: - Private Methods

extension SubscribedNodesModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }
    
    private func loadSubscriptions() {
        context.nodesService.loadSubscriptions { [weak self] result in
            switch result {
            case let .success(subscriptions):
                self?.subscriptions = subscriptions
            case .failure:
                self?.eventSubject.send(.setSubscriptionsState(.noConnection))
            }
        }
    }

    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { error in
            guard let error = error else {
                return
            }

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
}
