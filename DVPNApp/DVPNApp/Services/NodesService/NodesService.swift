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
    let stepToLoad = 10
}

private let constants = Constants()

final class NodesService {
    private let nodesStorage: StoresNodes
    private let sentinelService: SentinelService
    
    @Published private(set) var _availableNodesOfSelectedContinent: [SentinelNode] = []
    @Published private(set) var _loadedNodesCount: Int = 0
    @Published private(set) var _isAllLoaded: Void = ()
    
    @Published private(set) var _subscribedNodes: [SentinelNode] = []
    @Published private(set) var _isLoadingSubscriptions: Bool = true
    
    init(nodesStorage: StoresNodes, sentinelService: SentinelService) {
        self.nodesStorage = nodesStorage
        self.sentinelService = sentinelService
    }
}

extension NodesService: NodesServiceType {
    var availableNodesOfSelectedContinent: Published<[SentinelNode]>.Publisher {
        $_availableNodesOfSelectedContinent
    }
    
    var loadedNodesCount: Published<Int>.Publisher {
        $_loadedNodesCount
    }
    
    var isAllLoaded: Published<Void>.Publisher {
        $_isAllLoaded
    }
    
    var subscribedNodes: Published<[SentinelNode]>.Publisher {
        $_subscribedNodes
    }
    
    var isLoadingSubscriptions: Published<Bool>.Publisher {
        $_isLoadingSubscriptions
    }
    
    func loadAllNodesIfNeeded(completion: @escaping (() -> Void)) {
        if nodesStorage.sentinelNodes.isEmpty {
            loadAllNodes(completion: completion)
        }
    }
    
    func loadAllNodes(
        completion: (() -> Void)?
    ) {
        sentinelService.queryNodes(
            timeout: constants.timeout
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let nodes):
                self?.save(newSentinelNodes: nodes)
            }
            
            completion?()
        }
    }
    
    func loadNodesInfo(for continent: Continent?) {
        let sentinelNodes: [SentinelNode]
        
        self._loadedNodesCount = 0
        
        if let continent = continent {
            sentinelNodes = nodesStorage.sentinelNodes
                .filter { $0.node != nil }
                .filter { ContinentDecoder.shared.isInContinent(node: $0.node!, continent: continent) }
            
            _availableNodesOfSelectedContinent = sentinelNodes
        } else {
            sentinelNodes = nodesStorage.sentinelNodes
        }
        
        _isAllLoaded = ()
        
        let chunked = sentinelNodes.chunked(into: constants.stepToLoad)
        
        let group = DispatchGroup()
        
        chunked.enumerated().forEach { (index, littlePortion) in
            group.enter()
            
            loadLittlePortion(sentinelNodes: littlePortion) { [weak self] in
                guard let self = self else { return }
                
                self._loadedNodesCount = self._loadedNodesCount + constants.stepToLoad
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?._isAllLoaded = ()
        }
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
    
    func loadSubscriptions() {
        _isLoadingSubscriptions = true
        
        sentinelService.fetchSubscriptions { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
            case .success(let subscriptions):
                guard !subscriptions.isEmpty else {
                    self._isLoadingSubscriptions = false
                    return
                }
                self.loadNodes(from: Set(subscriptions.map { $0.node }))
            }
        }
    }
}

// MARK: - Private

extension NodesService {
    private func save(newSentinelNodes: [SentinelNode]) {
        var newSentinelNodesMutated = newSentinelNodes
        
        nodesStorage.sentinelNodes.forEach { sentinelNodeInDB in
            let index = newSentinelNodesMutated
                .firstIndex(where: { $0.address == sentinelNodeInDB.address })
            
            if let index = index {
                let newNode = sentinelNodeInDB.setFields(from: newSentinelNodesMutated[index])
                nodesStorage.save(sentinelNode: newNode)
                
                newSentinelNodesMutated.remove(at: index)
            } else {
                // TODO: @Tori delete node from db
            }
        }
        
        newSentinelNodesMutated.forEach {
            nodesStorage.save(sentinelNode: $0)
        }
    }
    
    private func loadLittlePortion(
        sentinelNodes: [SentinelNode],
        completion: @escaping () -> Void
    ) {
        let group = DispatchGroup()
        
        var loadedPortion: [Node] = []
        
        sentinelNodes.forEach { node in
            group.enter()
            
            loadNodeInfo(for: node) { result in
                if case let .success(node) = result {
                    loadedPortion.append(node)
                }
                
                group.leave()
            }
        }
        
        loadedPortion.forEach { newNode in
            if let row = self._availableNodesOfSelectedContinent
                .firstIndex(where: { $0.address == newNode.info.address }) {
                
                let newSentinelNode = _availableNodesOfSelectedContinent[row].set(node: newNode)
                _availableNodesOfSelectedContinent[row] = newSentinelNode
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    private func loadNodeInfo(
        for sentinelNode: SentinelNode,
        completion: @escaping (Result<Node, Error>) -> Void
    ) {
        self.sentinelService.fetchInfo(
            for: sentinelNode, timeout: constants.timeout
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                log.error(error)
                completion(.failure(NodesServiceError.failToLoadData))
            case .success(let node):
                self.nodesStorage.save(node: node, for: sentinelNode)
                completion(.success(node))
            }
        }
    }
    
    /// Use for loading nodes from subscriptions
    private func loadNodes(from addresses: Set<String>) {
        addresses.enumerated().forEach { index, address in
            sentinelService.queryNodeStatus(
                address: address,
                timeout: constants.timeout
            ) { [weak self] result in
                guard let self = self else { return }
                if index == addresses.count - 1 {
                    self._isLoadingSubscriptions = false
                }
                switch result {
                case .failure(let error):
                    log.error(error)
                case .success(let node):
                    self._subscribedNodes.append(node)
                }
            }
        }
    }
}
