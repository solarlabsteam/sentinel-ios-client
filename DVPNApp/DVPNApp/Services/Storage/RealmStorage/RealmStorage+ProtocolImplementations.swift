//
//  RealmStorage+ProtocolImplementations.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import RealmSwift
import SentinelWallet

// MARK: - StoresNodes

enum NodesServiceError: Error {
    case databaseFailure(String)
}

extension RealmStorage: StoresNodes {
    var sentinelNodes: [SentinelNode] {
        realm.objects(SentinelNodeObject.self).map { SentinelNode(managedObject: $0) }
    }
    
    func saveSentinelNodes(_ sentinelNodes: [SentinelNode]) {
        do {
            try realm.safeWrite() {
                try save(collection: sentinelNodes)
            }
        } catch {
            log.error(NodesServiceError.databaseFailure("Failed to save sentinelNodes \(sentinelNodes)"))
        }
    }
    
    func saveNode(_ node: Node, for sentinelNode: SentinelNode) {
        let fullSentinelNode = sentinelNode.set(node: node)
        
        do {
            try realm.safeWrite() {
                try save(object: fullSentinelNode)
            }
        } catch {
            log.error(NodesServiceError.databaseFailure("Failed to save node \(node)"))
        }
    }
}
