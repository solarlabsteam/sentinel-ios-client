//
//  NodesService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

private struct Constants {
    let timeout: TimeInterval = 5
}

private let constants = Constants()

final class NodesService {
    private let nodesStorage: StoresNodes
    private let sentinelService: SentinelService
    
    init(nodesStorage: StoresNodes, sentinelService: SentinelService) {
        self.nodesStorage = nodesStorage
        self.sentinelService = sentinelService
    }
}

extension NodesService: NodesServiceType {
    func loadAllNodesIfNeeded() {
        if nodesStorage.sentinelNodes.isEmpty {
            loadAllNodes()
        }
    }
    
    func loadNodesInfo(for continent: Continent?) {
        let sentinelNodes: [SentinelNode]
        
        if let continent = continent {
            sentinelNodes = nodesStorage.sentinelNodes
                .filter { $0.node != nil }
                .filter { ContinentDecoder.shared.isInContinent(node: $0.node!, continent: continent) }
        } else {
            sentinelNodes = nodesStorage.sentinelNodes.filter { $0.node == nil }
        }
        
        let chunked = sentinelNodes.chunked(into: 10)
        
        let group = DispatchGroup()
        
        for littlePortion in chunked {
            group.enter()
            
            loadLittlePortion(sentinelNodes: littlePortion) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {}
    }
    
    func nodesCount(for continent: Continent) -> Int {
        nodesStorage.sentinelNodes
            .map { $0.node }
            .compactMap { $0 }
            .filter { ContinentDecoder().isInContinent(node: $0, continent: continent) }
            .count
    }
    
    var nodes: [SentinelNode] {
        nodesStorage.sentinelNodes
    }
}

// MARK: - Private

extension NodesService {
    private func loadAllNodes() {
        sentinelService.queryNodes(
            timeout: constants.timeout
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
                // TODO: @Tori Do sth if error - retry when opens continents
            case .success(let nodes):
                self.nodesStorage.save(sentinelNodes: nodes)
            }
        }
    }
    
    private func loadLittlePortion(
        sentinelNodes: [SentinelNode],
        completion: @escaping () -> Void
    ) {
        let group = DispatchGroup()
        
        sentinelNodes.forEach { node in
            group.enter()
            
            loadNodeInfo(for: node) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func loadNodeInfo(
        for sentinelNode: SentinelNode,
        completion: @escaping () -> Void
    ) {
        self.sentinelService.fetchInfo(
            for: sentinelNode, timeout: constants.timeout
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let node):
                self.nodesStorage.save(node: node, for: sentinelNode)
                completion()
            }
        }
    }
}
