//
//  HomeViewModel.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage
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
        case subscribe(node: DVPNNodeInfo)
        case details(Node, isSubscribed: Bool)
        case accountInfo
        case sentinel
        case title(String)
    }

    enum PageType {
        case extra
        case selector

        var title: String {
            switch self {
            case .extra:
                return L10n.Home.Extra.title
            case .selector:
                return L10n.Home.Node.title
            }
        }
    }

    @Published private(set) var locations: [NodeSelectionRowViewModel] = []
    private(set) var subscriptions: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<Node> = []
    
    private let model: HomeModel
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoadingNodes: Bool = true
    @Published var isAllLoaded: Bool = false
    @Published var isLoadingSubscriptions: Bool = true

    @Published var currentPage: PageType = .selector
    @Published var selectedTab: NodeType = .subscribed

    private var statusObservationToken: NotificationToken?
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    init(model: HomeModel, router: Router) {
        self.model = model
        self.router = router

        handeEvents()
        startObservingStatuses()

        $currentPage
            .sink(receiveValue: {
                UIImpactFeedbackGenerator.lightFeedback()
                router.play(event: .title($0.title))
            })
            .store(in: &cancellables)

        $selectedTab
            .sink(receiveValue: { _ in UIImpactFeedbackGenerator.lightFeedback()})
            .store(in: &cancellables)

        model.loadNodes()
    }

    func toggleLocation(with id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let node = nodes.first(where: { $0.info.address == id }) else {
            router.play(event: .error(HomeViewModelError.unavailableNode))
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

    func loadNodes() {
        guard !isAllLoaded else { return }
        model.loadNodes()
    }

    @objc
    func didTapAccountInfoButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .accountInfo)
    }

    func viewWillAppear() {
        model.connectIfNeeded()
    }

    func openDetails(for id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let node = nodes.first(where: { $0.info.address == id }) else {
            router.play(event: .error(HomeViewModelError.unavailableNode))
            return
        }
        router.play(event: .details(node, isSubscribed: model.isSubscribed(to: node.info.address)))
    }

    func openMore() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .sentinel)
    }
}

extension HomeViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(nodes):
                    self?.update(nodes: Set(nodes))
                case let .showLoadingNodes(state):
                    self?.isLoadingNodes = state
                case let .showLoadingSubscriptions(state):
                    self?.isLoadingSubscriptions = state
                case .allLoaded:
                    self?.isAllLoaded = true
                case let .append(subscribedNode):
                    self?.nodes.insert(subscribedNode)
                    let countryCode = CountryFormatter.code(for: subscribedNode.info.location.country) ?? ""

                    let model = NodeSelectionRowViewModel(
                        from: subscribedNode,
                        icon: Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
                    )

                    self?.subscriptions.append(model)

                case .connect:
                    self?.router.play(event: .connect)
                case .reloadSubscriptions:
                    self?.subscriptions = []
                    self?.isLoadingSubscriptions = true
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

    private func update(nodes: Set<Node>) {
        let newNodes = nodes.subtracting(self.nodes)
        let newLocations = newNodes.map { node -> NodeSelectionRowViewModel in
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""

            return NodeSelectionRowViewModel(
                from: node,
                icon: Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
            )
        }
        locations.append(contentsOf: newLocations)
        self.nodes.formUnion(nodes)
    }

    private func connectToRandomNode() {
        guard let node = nodes.first(where: { $0.latency < 1 }) ?? nodes.first else {
            router.play(event: .error(HomeViewModelError.unavailableNode))
            return
        }

        toggle(node: node)
    }

    private func toggle(node: Node) {
        let isSubscribedToNode = model.isSubscribed(to: node.info.address)
        guard isSubscribedToNode else {
            router.play(event: .subscribe(node: node.info))
            return
        }

        model.save(nodeAddress: node.info.address)
    }
}
