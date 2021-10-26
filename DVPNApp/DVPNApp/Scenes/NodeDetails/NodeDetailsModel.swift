//
//  NodeDetailsModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Combine
import SentinelWallet

enum NodeDetailsModelEvent {
    case update(node: SentinelNode)
    case error(Error)
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

    init(context: Context, node: SentinelNode, isSubscribed: Bool) {
        self.context = context
        self.node = node
        self.isSubscribed = isSubscribed
    }
}

extension NodeDetailsModel {
    func refresh() {
        self.eventSubject.send(.update(node: node))
    }
    
    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
    }
}
