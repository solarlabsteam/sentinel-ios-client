//
//  AvailableNodesModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 18.10.2021.
//

import Foundation
import Combine
import SentinelWallet

private struct Constants {
    let timeout: TimeInterval = 5
    let limit: UInt64 = 20
}

private let constants = Constants()

enum AvailableNodesModelEvent {
    case error(Error)

    case showLoadingNodes(state: Bool)

    case allLoaded
    
    case update(locations: [SentinelNode])
    case connect
}

final class AvailableNodesModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager & HasNodesService
    private let context: Context
    private let continent: Continent

    private let eventSubject = PassthroughSubject<AvailableNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<AvailableNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var subscriptions: [SentinelWallet.Subscription] = []
    private var offset: UInt64 = 0

    init(context: Context, continent: Continent) {
        self.context = context
        self.continent = continent
    }
}

extension AvailableNodesModel {
    func loadNodes() {
        // TODO: @Tori update nodes in db, pagination
        let nodes = context.nodesService.nodes
            .filter { $0.node != nil }
            .filter { ContinentDecoder().isInContinent(node: $0.node!, continent: continent) }
        
        self.eventSubject.send(.update(locations: nodes))
    }

    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
        eventSubject.send(.connect)
    }

    func isSubscribed(to node: String) -> Bool {
        subscriptions.contains(where: { $0.node == node })
    }
}

// MARK: - Private Methods

extension AvailableNodesModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }
}
