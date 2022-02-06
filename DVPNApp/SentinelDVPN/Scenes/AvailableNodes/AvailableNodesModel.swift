//
//  AvailableNodesModel.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import Foundation
import Combine
import SentinelWallet

enum AvailableNodesModelEvent {
    case error(Error)

    case setLoadedNodesCount(_ count: Int)

    case allLoaded(Bool)
    
    case update(locations: [SentinelNode])
}

final class AvailableNodesModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasTunnelManager & HasNodesService
    private let context: Context
    private let continent: Continent

    private let eventSubject = PassthroughSubject<AvailableNodesModelEvent, Never>()
    var eventPublisher: AnyPublisher<AvailableNodesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()

    private var subscriptions: [SentinelWallet.Subscription] = []

    init(context: Context, continent: Continent) {
        self.context = context
        self.continent = continent
        
        context.nodesService.subscriptions
            .sink(receiveValue: { [weak self] subscriptions in
                self?.subscriptions = subscriptions
            })
            .store(in: &cancellables)
    }
}

extension AvailableNodesModel {
    func loadNodes() {
        context.nodesService.loadNodesInfo(for: continent)
    }
    
    func subscribeToEvents() {
        context.nodesService.availableNodesOfSelectedContinent
            .map { .update(locations: $0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
        
        context.nodesService.isAllLoaded
            .map { .allLoaded($0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
        
        context.nodesService.loadedNodesCount
            .map { .setLoadedNodesCount($0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }

    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
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
