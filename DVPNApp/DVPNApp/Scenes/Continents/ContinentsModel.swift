//
//  ContinentsModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import Combine
import SentinelWallet

enum ContinentsModelEvent {
    case error(Error)
    case update(locations: [SentinelNode])
    case connect
    case setNumberOfNodesInContinent
}

final class ContinentsModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
        & HasDNSServersStorage & HasTunnelManager & HasNodesService
    private let context: Context

    private let eventSubject = PassthroughSubject<ContinentsModelEvent, Never>()
    var eventPublisher: AnyPublisher<ContinentsModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private(set) var subscriptions: [SentinelWallet.Subscription] = []
    private var reloadOnNextAppear = false
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.context = context
        
        fetchWalletInfo()
        loadSubscriptions()
        
        context.nodesService.loadAllNodesIfNeeded { result in
            if case let .success(nodes) = result {
                context.nodesService.loadNodesInfo(for: nodes)
            }
        }
        
        context.nodesService.subscriptions
            .sink(receiveValue: { [weak self] subscriptions in
                self?.subscriptions = subscriptions
            })
            .store(in: &cancellables)
        
        context.nodesService.isAllLoaded
            .sink(receiveValue: { [weak self] isAllLoaded in
                if isAllLoaded {
                    self?.eventSubject.send(.setNumberOfNodesInContinent)
                }
            }).store(in: &cancellables)
    }
    
    func setNumberOfNodesInContinent() -> [Continent: Int] {
        var numberOfNodesInContinent: [Continent: Int] = [:]
        
        Continent.allCases.forEach {
            numberOfNodesInContinent[$0] = context.nodesService.nodesCount(for: $0)
        }
        
        return numberOfNodesInContinent
    }

    func setNodes() {
        eventSubject.send(.update(locations: context.nodesService.nodes))
    }

    func save(nodeAddress: String) {
        context.connectionInfoStorage.set(lastSelectedNode: nodeAddress)
        context.connectionInfoStorage.set(shouldConnect: true)
        eventSubject.send(.connect)
    }

    func isSubscribed(to node: String) -> Bool {
        subscriptions.contains(where: { $0.node == node })
    }

    func connectIfNeeded() {
        if context.connectionInfoStorage.shouldConnect() {
            eventSubject.send(.connect)
        }
    }

    func disconnect() {
        context.tunnelManager.startDeactivationOfActiveTunnel()
    }
}

// MARK: - Private Methods

extension ContinentsModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }

    private func fetchWalletInfo() {
        context.walletService.fetchAuthorization { error in
            guard let error = error else {
                return
            }

            log.error(error)
        }

        context.walletService.fetchTendermintNodeInfo { [weak self] result in
            switch result {
            case .success(let info):
                log.debug(info)
            case .failure(let error):
                self?.show(error: error)
            }
        }
    }
    
    private func loadSubscriptions() {
        context.nodesService.loadSubscriptions { [weak self] result in
            switch result {
            case let .success(subscriptions):
                self?.subscriptions = subscriptions
            case let .failure(error):
                self?.show(error: error)
            }
        }
    }
}
