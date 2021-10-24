//
//  NodesServiceType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

protocol NodesServiceType {
    func loadAllNodesIfNeeded()
    func loadNodesInfo(for continent: Continent?)
    func nodesCount(for continent: Continent) -> Int
    
    var nodes: [SentinelNode] { get }
}

extension NodesServiceType {
    func loadNodesInfo() {
        loadNodesInfo(for: nil)
    }
}
