//
//  ContinentsViewModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage
import NetworkExtension

enum NodeError: LocalizedError {
    case unavailableNode

    var errorDescription: String? {
        switch self {
        case .unavailableNode:
            return L10n.Error.unavailableNode
        }
    }
}

final class ContinentsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case connect
        case subscribe(node: DVPNNodeInfo, delegate: PlansViewModelDelegate)
        case openNodes(Continent, delegate: PlansViewModelDelegate)
    }
    
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: ContinentsModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]

    private var statusObservationToken: NotificationToken?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    init(model: ContinentsModel, router: Router) {
        self.model = model
        self.router = router

        handeEvents()
        startObservingStatuses()
        
        numberOfNodesInContinent = model.setNumberOfNodesInContinent()
        
        model.setNodes()
    }
    
    func viewWillAppear() {
        model.connectIfNeeded()
    }
}

// MARK: - PlansViewModelDelegate

extension ContinentsViewModel: PlansViewModelDelegate {
    func openConnection() {
        model.connectIfNeeded()
    }
}

// MARK: - Buttons actions

extension ContinentsViewModel {
    func toggleLocation(with id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(NodeError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    func toggleRandomLocation() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard connectionStatus != .connected else {
            model.disconnect()
            return
        }
        guard !nodes.isEmpty else { return }
        guard !model.subscriptions.isEmpty else {
            connectToRandomNode()
            return
        }

        guard let nodeId = model.subscriptions.randomElement()?.node else {
            connectToRandomNode()
            return
        }

        toggleLocation(with: nodeId)
    }
    
    func openNodes(for continent: Continent) {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .openNodes(continent, delegate: self))
    }
}

extension ContinentsViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(nodes):
                    self?.nodes.formUnion(nodes)
                case .connect:
                    self?.router.play(event: .connect)
                case let .setNumberOfNodesInContinent(numberOfNodesInContinent):
                    self?.numberOfNodesInContinent = numberOfNodesInContinent
                }
            }
            .store(in: &cancellables)
    }

    private func startObservingStatuses() {
        statusObservationToken = NotificationCenter.default.observe(
            name: .NEVPNStatusDidChange,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] statusChangeNotification in
            if let session = statusChangeNotification.object as? NETunnelProviderSession {
                self?.connectionStatus = .init(from: session.status == .connected)
            }
        }
    }

    private func connectToRandomNode() {
        guard let sentinelNode = nodes.filter({ $0.node?.latency ?? 0 < 1 }).randomElement() ?? nodes.first,
              let node = sentinelNode.node else {
                  router.play(event: .error(NodeError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
            router.play(event: .subscribe(node: node.info, delegate: self))
            return
        }

        model.save(nodeAddress: node.info.address)
    }
}
