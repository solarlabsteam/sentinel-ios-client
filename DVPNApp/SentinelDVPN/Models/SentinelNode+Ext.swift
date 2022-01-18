//
//  SentinelNode+Ext.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 23.10.2021.
//

import SentinelWallet

extension SentinelNode {
    func set(node: Node) -> SentinelNode {
        return .init(
            address: self.address,
            provider: self.provider,
            price: self.price,
            remoteURL: self.remoteURL,
            node: node
        )
    }
    
    func setFields(from sentinelNode: SentinelNode) -> SentinelNode {
        return .init(
            address: sentinelNode.address,
            provider: sentinelNode.provider,
            price: sentinelNode.price,
            remoteURL: sentinelNode.remoteURL,
            node: self.node
        )
    }
}

// MARK: - Hashable

extension SentinelNode: Hashable {
    public static func == (lhs: SentinelNode, rhs: SentinelNode) -> Bool {
        lhs.address == rhs.address
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
