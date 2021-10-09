//
//  NodeDetailsModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Combine
import SentinelWallet

enum NodeDetailsModelEvent {
    case update(node: Node)
    case error(Error)
}

final class NodeDetailsModel {
    typealias Context = HasStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<NodeDetailsModelEvent, Never>()
    var eventPublisher: AnyPublisher<NodeDetailsModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private let node: Node
    let isSubscribed: Bool

    init(context: Context, node: Node, isSubscribed: Bool) {
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
        context.storage.set(lastSelectedNode: nodeAddress)
        context.storage.set(shouldConnect: true)
    }
}
