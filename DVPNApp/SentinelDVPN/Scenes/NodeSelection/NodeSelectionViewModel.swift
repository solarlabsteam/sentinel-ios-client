//
//  NodeSelectionViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 18.01.2022.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import NetworkExtension

enum NodeType: CaseIterable {
    case subscribed
    case available

    var title: String {
        switch self {
        case .subscribed:
            return L10n.Home.Node.Subscribed.title.uppercased()
        case .available:
            return L10n.Home.Node.All.title.uppercased()
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
    enum Route {
        case error(Error)
        case connect
//        case subscribe(node: DVPNNodeInfo, delegate: PlansViewModelDelegate)
        case details(SentinelNode, isSubscribed: Bool)
        case accountInfo
        case sentinel
        case solarLabs
//        case dns(DNSSettingsViewModelDelegate?, DNSServerType)
//        case openNodes(Continent, delegate: PlansViewModelDelegate)
    }
    
    @Published private(set) var subscriptions: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: NodeSelectionModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoadingSubscriptions: Bool = true
    
    @Published var selectedTab: NodeType = .subscribed
    @Published var server: DNSServerType = .default
    
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]

    private var statusObservationToken: NotificationToken?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty

    @Published var showAccountPopover = false

    init(model: NodeSelectionModel) {
        self.model = model

        handeEvents()
        startObservingStatuses()
        
        $selectedTab
            .sink(receiveValue: { _ in
#if os(iOS)
                UIImpactFeedbackGenerator.lightFeedback()
#endif
            })
            .store(in: &cancellables)
        
        numberOfNodesInContinent = model.numberOfNodesInContinent

        model.refreshDNS()
        model.subscribeToEvents()
        model.setNodes()
    }
    
    func viewWillAppear() {
        model.connectIfNeeded()
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
//                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    @objc
    func didTapAccountInfoButton() {
//        router.play(event: .accountInfo)
    }

    func openDetails(for id: String) {
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
//                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
//        router.play(event: .details(sentinelNode, isSubscribed: model.isSubscribed(to: node.info.address)))
    }
    
    func openNodes(for continent: Continent) {
//        router.play(event: .openNodes(continent, delegate: self))
    }

    func openMore() {
//        router.play(event: .sentinel)
    }

    func openSolarLabs() {
//        router.play(event: .solarLabs)
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
                    #warning("TODO")
//                    self.router.play(event: .error(error))
                case let .update(nodes):
                    self.nodes.formUnion(nodes)
                case let .showLoadingSubscriptions(state):
                    self.isLoadingSubscriptions = state
                case let .set(subscribedNodes):
                    self.set(subscribedNodes: subscribedNodes)
                case let .setSubscriptionsState(state):
                    self.subscriptionsState = state
                case .connect:
                    #warning("TODO")
//                    self.router.play(event: .connect)
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
