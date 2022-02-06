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

enum SubscribedNodesState: Hashable {
    case all
    case details(SentinelNode)
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

    case subscribed(SubscribedNodesState)
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
    
    private let model: NodeSelectionModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoadingSubscriptions: Bool = true

    @Published var selectedTab: NodeType = .subscribed(.all)
    @Published var server: DNSServerType = .default

    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty

    @Published var showAccountPopover = false

    init(model: NodeSelectionModel) {
        self.model = model

        handeEvents()
        numberOfNodesInContinent = model.numberOfNodesInContinent

        model.refreshDNS()
        model.subscribeToEvents()
        model.setNodes()
    }
}

//// MARK: - DNSSettingsViewModelDelegate
//
//extension HomeViewModel: DNSSettingsViewModelDelegate {
//    func update(to server: DNSServerType) {
//        self.server = server
//    }
//}

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

        selectedTab = .subscribed(.details(sentinelNode))
    }

    func openContinent(key: Continent) {
        selectedTab = .available(.continent(key))
    }

    func closeDetails() {
        selectedTab = .subscribed(.all)
    }

    func closeContinent() {
        selectedTab = .available(.all)
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
                case let .select(server):
                    #warning("TODO")
//                    self.update(to: server)
                case .setNumberOfNodesInContinent:
                    #warning("TODO handle nodes update the way it won't cause all view to reload")
//                    self.numberOfNodesInContinent = self.model.numberOfNodesInContinent
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
            nodes.insert(subscribedNode)
            
            guard let node = subscribedNode.node else { return }
            
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""
            
            let flagImage: ImageAsset.Image?
            
            #warning("replace all the original images on macOS with rounded")
            flagImage = Flag(countryCode: countryCode)?.originalImage
            
            let model = NodeSelectionRowViewModel(
                from: node,
                icon: flagImage ?? Asset.Tokens.dvpn.image
            )
            
            if !subscriptions.contains(where: { $0.id == model.id }) {
                subscriptions.append(model)
            }
        }
    }

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
//            router.play(event: .subscribe(node: node.info, delegate: self))
            return
        }

        model.save(nodeAddress: node.info.address)
    }
}
