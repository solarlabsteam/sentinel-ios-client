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
import NetworkExtension
import AlertToast

enum NodeType: CaseIterable {
    case subscribed
    case available

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
    
    @Published var selectedTab: NodeType = .subscribed
    @Published var server: DNSServerType = .default

    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]

    private var statusObservationToken: NotificationToken?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty

    @Published var showAccountPopover = false

    init(model: NodeSelectionModel) {
        self.model = model

        handeEvents()
        startObservingStatuses()
        
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
//
//// MARK: - PlansViewModelDelegate
//
//extension HomeViewModel: PlansViewModelDelegate {
//    func openConnection() {
//        model.connectIfNeeded()
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
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  show(error: NodeSelectionViewModelError.unavailableNode)
                  return
              }
        
//        router.play(event: .details(sentinelNode, isSubscribed: model.isSubscribed(to: node.info.address)))
    }
    
    func openNodes(for continent: Continent) {
//        router.play(event: .openNodes(continent, delegate: self))
    }
    
    func openDNSServersSelection() {
//        router.play(event: .dns(self, server))
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
                    self.numberOfNodesInContinent = self.model.numberOfNodesInContinent
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

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
//            router.play(event: .subscribe(node: node.info, delegate: self))
            return
        }

        model.save(nodeAddress: node.info.address)
    }
}
