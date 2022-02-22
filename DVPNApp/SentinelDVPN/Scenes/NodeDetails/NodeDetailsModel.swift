//
//  NodeDetailsModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Combine
import SentinelWallet

enum NodeDetailsModelEvent {
    case update(node: SentinelNode)
    case isConnecting(Bool)
}

final class NodeDetailsModel {
    typealias Context = HasConnectionInfoStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<NodeDetailsModelEvent, Never>()
    var eventPublisher: AnyPublisher<NodeDetailsModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private let node: SentinelNode
    let isSubscribed: Bool
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context, node: SentinelNode, isSubscribed: Bool) {
        self.context = context
        self.node = node
        self.isSubscribed = isSubscribed
        
        subscribeToEvent()
    }
}

extension NodeDetailsModel {
    func refresh() {
        eventSubject.send(.update(node: node))
    }
    
    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
    }
    
    private func subscribeToEvent() {
        context.connectionInfoStorage.isConnectingPublisher
            .map { .isConnecting($0) }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }
}
