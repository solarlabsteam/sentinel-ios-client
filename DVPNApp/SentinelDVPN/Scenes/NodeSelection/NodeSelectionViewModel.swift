//
//  NodeSelectionViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 18.01.2022.
//

import Cocoa
import FlagKit
import SentinelWallet
import Combine
import AlertToast

enum NodesColumnState: Hashable {
    case all
    case details(SentinelNode, isSubscribed: Bool)
}

enum ContinentsState: Hashable {
    case all
    case continent(Continent)
}

enum NodeType: CaseIterable, Hashable {
    static func == (lhs: NodeType, rhs: NodeType) -> Bool {
        switch (lhs, rhs) {
        case (.available, .subscribed), (.subscribed, .available):
            return false
        default:
            return true
        }
    }

    static var allCases: [NodeType] {
        [.subscribed(.all), .available(.all)]
    }

    case subscribed(NodesColumnState)
    case available(ContinentsState)

    var title: String {
        switch self {
        case .subscribed:
            return L10n.Home.Node.Subscribed.title
        case .available:
            return L10n.Home.Node.All.title
        }
    }
}

enum NodeSelectionViewModelError: LocalizedError {
    case unavailableNode

    var errorDescription: String? {
        switch self {
        case .unavailableNode:
            return L10n.Error.unavailableNode
        }
    }
}

final class NodeSelectionViewModel: ObservableObject {
    @Published private(set) var subscriptions: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<SentinelNode> = []
    @Published private(set) var stackExists: Bool = false
    
    private let model: NodeSelectionModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoadingSubscriptions: Bool = true

    @Published var selectedTab: NodeType = .subscribed(.all)
    @Published var server: DNSServerType = .default

    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty
    
    @Published var showPlansSheet = false {
        didSet {
            if showPlansSheet == false {
                nodeToToggle = nil
            }
        }
    }
    
    @Published var nodeToToggle: Node?
    
    @Published var isConnectionButtonDisabled = false

    init(model: NodeSelectionModel) {
        self.model = model

        handeEvents()
        numberOfNodesInContinent = model.numberOfNodesInContinent
        
        model.subscribeToEvents()
        model.setNodes()
    }
}

// MARK: - Buttons actions

extension NodeSelectionViewModel {
    func toggleLocation(with id: String) {
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  show(error: NodeSelectionViewModelError.unavailableNode)
                  return
              }
        
        toggle(node: node)
    }

    func openDetails(for id: String) {
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }) else {
            show(error: NodeSelectionViewModelError.unavailableNode)
            return
        }
        
        let isSubscribed = model.isSubscribed(to: sentinelNode.address)

        selectedTab = .subscribed(.details(sentinelNode, isSubscribed: isSubscribed))
    }

    func openContinent(key: Continent) {
        selectedTab = .available(.continent(key))
    }

    func closeDetails() {
        selectedTab = .subscribed(.all)
    }

    func closeContinent() {
        selectedTab = .available(.all)
        
        // Counting numberOfNodesInContinent in global queue
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let numberOfNodesInContinent = self.model.numberOfNodesInContinent
            
            DispatchQueue.main.async {
                self.numberOfNodesInContinent = numberOfNodesInContinent
            }
        }
    }
}

extension NodeSelectionViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case let .error(error):
                    self.show(error: error)
                case let .update(nodes):
                    self.nodes.formUnion(nodes)
                case let .showLoadingSubscriptions(state):
                    self.isLoadingSubscriptions = state
                case let .set(subscribedNodes):
                    self.set(subscribedNodes: subscribedNodes)
                case let .setSubscriptionsState(state):
                    self.subscriptionsState = state
                case .reloadSubscriptions:
                    self.subscriptions = []
                    self.isLoadingSubscriptions = true
                case let .isConnecting(isConnecting):
                    self.isConnectionButtonDisabled = isConnecting
                }
            }
            .store(in: &cancellables)
    }

    private func show(error: Error) {
        alertContent = (
            true,
            AlertToast(type: .error(NSColor.systemRed.asColor), title: error.localizedDescription)
        )
    }
    
    private func set(subscribedNodes: [SentinelNode]) {
        subscribedNodes.forEach { subscribedNode in
            guard let node = subscribedNode.node,
                    !subscriptions.contains(where: { $0.id == node.info.address }) else { return }
            nodes.insert(subscribedNode)
            
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""
            let flagImage = Flag(countryCode: countryCode)?.originalImage
            
            let model = NodeSelectionRowViewModel(
                from: node,
                icon: flagImage ?? Asset.Tokens.dvpn.image
            )
            
            subscriptions.append(model)
        }
    }

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
            showPlansSheet = true
            nodeToToggle = node
            return
        }
        
        model.save(nodeAddress: node.info.address)
    }
}
