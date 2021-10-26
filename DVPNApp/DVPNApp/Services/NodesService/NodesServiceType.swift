//
//  NodesServiceType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

protocol NodesServiceType {
    var availableNodesOfSelectedContinent: Published<[SentinelNode]>.Publisher { get }
    var loadedNodesCount: Published<Int>.Publisher { get }
    var isAllLoaded: Published<Void>.Publisher { get }
    var nodes: [SentinelNode] { get }
    
    func loadAllNodesIfNeeded(completion: @escaping (() -> Void))
    func loadAllNodes(completion: (() -> Void)?)
    func loadNodesInfo(for continent: Continent?)
    func nodesCount(for continent: Continent) -> Int
    func loadSubscriptions()
    
    var subscribedNodes: Published<[SentinelNode]>.Publisher { get }
    var isLoadingSubscriptions: Published<Bool>.Publisher { get }
}

extension NodesServiceType {
    func loadAllNodes() {
        loadAllNodes(completion: nil)
    }
    
    func loadNodesInfo() {
        loadNodesInfo(for: nil)
    }
}
