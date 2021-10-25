//
//  AvailableNodesViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 18.10.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage
import NetworkExtension

final class AvailableNodesViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case connect
        case subscribe(node: DVPNNodeInfo)
        case details(SentinelNode, isSubscribed: Bool)
        case accountInfo
    }

    @Published private(set) var locations: [NodeSelectionRowViewModel] = []
    private(set) var nodes: Set<SentinelNode> = []
    
    private let model: AvailableNodesModel
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoadingNodes: Bool = true
    @Published var isAllLoaded: Bool = false
    
    let continent: Continent

    private var statusObservationToken: NotificationToken?

    init(continent: Continent, model: AvailableNodesModel, router: Router) {
        self.continent = continent
        self.model = model
        self.router = router

        handeEvents()

        model.loadNodes()
    }
    
    func loadNodes() {
        guard !isAllLoaded else { return }
        model.loadNodes()
    }
}

// MARK: - Buttons actions

extension AvailableNodesViewModel {
    func openDetails(for id: String) {
        UIImpactFeedbackGenerator.lightFeedback()
        guard let node = nodes.first(where: { $0.node!.info.address == id }) else {
            router.play(event: .error(HomeViewModelError.unavailableNode))
            return
        }
        router.play(event: .details(node, isSubscribed: model.isSubscribed(to: node.node!.info.address)))
    }
    
    @objc
    func didTapAccountInfoButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .accountInfo)
    }
}

// MARK: - Private

extension AvailableNodesViewModel {
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
                case .allLoaded:
                    self?.isAllLoaded = true
                case .connect:
                    self?.router.play(event: .connect)
                }
            }
            .store(in: &cancellables)
    }

    private func update(nodes: Set<SentinelNode>) {
        let newNodes = nodes.subtracting(self.nodes)
        let newLocations = newNodes.map { node -> NodeSelectionRowViewModel in
            let countryCode = CountryFormatter.code(for: node.node!.info.location.country) ?? ""

            return NodeSelectionRowViewModel(
                from: node.node!,
                icon: Flag(countryCode: countryCode)?.image(style: .roundedRect) ?? Asset.Tokens.dvpn.image
            )
        }
        locations.append(contentsOf: newLocations)
        self.nodes.formUnion(nodes)
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
