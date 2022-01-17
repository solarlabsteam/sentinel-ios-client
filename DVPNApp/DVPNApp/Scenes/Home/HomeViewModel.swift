//
//  HomeViewModel.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

#if os(iOS)
import UIKit
#endif

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

enum HomeViewModelError: LocalizedError {
    case unavailableNode

    var errorDescription: String? {
        switch self {
        case .unavailableNode:
            return L10n.Error.unavailableNode
        }
    }
}

final class HomeViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case connect
        case subscribe(node: DVPNNodeInfo, delegate: PlansViewModelDelegate)
        case details(SentinelNode, isSubscribed: Bool)
        case accountInfo
        case sentinel
        case solarLabs
        case title(String)
        case dns(DNSSettingsViewModelDelegate?, DNSServerType)
        case openNodes(Continent, delegate: PlansViewModelDelegate)
    }

    enum PageType: Int, CaseIterable, Equatable {
        case selector
        case extra

        var title: String {
            switch self {
            case .extra:
                return L10n.Home.Extra.title
            case .selector:
                return L10n.Home.Node.title
            }
        }
    }
    
    @Published private(set) var subscriptions: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: HomeModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoadingSubscriptions: Bool = true

    @Published var currentPage: PageType = .selector
    @Published var selectedTab: NodeType = .subscribed
    @Published var server: DNSServerType = .default
    
    @Published var numberOfNodesInContinent: [Continent: Int] = [:]

    private var statusObservationToken: NotificationToken?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    
    @Published private(set) var subscriptionsState: SubscriptionsState = .empty

    init(model: HomeModel, router: Router) {
        self.model = model
        self.router = router

        handeEvents()
        startObservingStatuses()

        $currentPage
            .sink(receiveValue: {
#if os(iOS)
                UIImpactFeedbackGenerator.lightFeedback()
#endif
                router.play(event: .title($0.title))
            })
            .store(in: &cancellables)

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

// MARK: - DNSSettingsViewModelDelegate

extension HomeViewModel: DNSSettingsViewModelDelegate {
    func update(to server: DNSServerType) {
        self.server = server
    }
}

// MARK: - PlansViewModelDelegate

extension HomeViewModel: PlansViewModelDelegate {
    func openConnection() {
        model.connectIfNeeded()
    }
}

// MARK: - Buttons actions

extension HomeViewModel {
    func toggleLocation(with id: String) {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }

    func toggleRandomLocation() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        guard connectionStatus != .connected else {
            model.disconnect()
            return
        }
        guard !nodes.isEmpty else { return }
        guard !subscriptions.isEmpty else {
            connectToRandomNode()
            return
        }

        guard let nodeId = subscriptions.sorted(by: { $0.latency < $1.latency }).first?.id else {
            connectToRandomNode()
            return
        }

        toggleLocation(with: nodeId)
    }

    @objc
    func didTapAccountInfoButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .accountInfo)
    }

    func openDetails(for id: String) {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address ?? "" == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
        router.play(event: .details(sentinelNode, isSubscribed: model.isSubscribed(to: node.info.address)))
    }
    
    func openNodes(for continent: Continent) {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .openNodes(continent, delegate: self))
    }

    func openMore() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .sentinel)
    }

    func openSolarLabs() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .solarLabs)
    }

    func openDNSServersSelection() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .dns(self, server))
    }
}

extension HomeViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case let .error(error):
                    self.router.play(event: .error(error))
                case let .update(nodes):
                    self.nodes.formUnion(nodes)
                case let .showLoadingSubscriptions(state):
                    self.isLoadingSubscriptions = state
                case let .set(subscribedNodes):
                    self.set(subscribedNodes: subscribedNodes)
                case let .setSubscriptionsState(state):
                    self.subscriptionsState = state
                case .connect:
                    self.router.play(event: .connect)
                case .reloadSubscriptions:
                    self.subscriptions = []
                    self.isLoadingSubscriptions = true
                case let .select(server):
                    self.update(to: server)
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
            
#if os(iOS)
            flagImage = Flag(countryCode: countryCode)?.image(style: .roundedRect)
#elseif os(macOS)
            #warning("replace all the original images on macOS with rounded")
            flagImage = Flag(countryCode: countryCode)?.originalImage
#endif
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

    private func connectToRandomNode() {
        guard let sentinelNode = nodes.filter({ $0.node?.latency ?? 0 < 1 }).randomElement() ?? nodes.first,
              let node = sentinelNode.node else {
                  router.play(event: .error(HomeViewModelError.unavailableNode))
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
