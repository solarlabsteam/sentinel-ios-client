//
//  AvailableNodesViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 18.10.2021.
//

#if os(iOS)
import UIKit
#endif

import Foundation
import FlagKit
import SentinelWallet
import Combine
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
    private(set) var loadedNodesCount: Int = 0
    
    private let model: AvailableNodesModel
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoadingNodes: Bool = true
    
    @Published var isAllLoaded: Bool = false {
        didSet {
            if isAllLoaded {
                isLoadingNodes = false
            }
        }
    }
    
    let continent: Continent

    private var statusObservationToken: NotificationToken?

    init(continent: Continent, model: AvailableNodesModel, router: Router) {
        self.continent = continent
        self.model = model
        self.router = router

        handeEvents()

        model.loadNodes()
        model.subscribeToEvents()
    }
    
    func loadNodes() {
        guard !isAllLoaded else { return }
        model.loadNodes()
    }
    
    func setLoadingNodes() {
        if !isAllLoaded {
            self.isLoadingNodes = true
        }
    }
}

// MARK: - Buttons actions

extension AvailableNodesViewModel {
    func toggleLocation(with id: String) {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
        toggle(node: node)
    }
    
    func openDetails(for id: String) {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address == id }),
              let node = sentinelNode.node else {
                  router.play(event: .error(HomeViewModelError.unavailableNode))
                  return
              }
        
        router.play(event: .details(sentinelNode, isSubscribed: model.isSubscribed(to: node.info.address)))
    }
    
    @objc
    func didTapAccountInfoButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
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
                case let .setLoadedNodesCount(loadedNodesCount):
                    self?.set(loadedNodesCount: loadedNodesCount)
                case let .allLoaded(isAllLoaded):
                    self?.isAllLoaded = isAllLoaded
                case .connect:
                    self?.router.play(event: .connect)
                }
            }
            .store(in: &cancellables)
    }

    private func update(nodes: Set<SentinelNode>) {
        let newNodes = nodes.subtracting(self.nodes)
        let newLocations = newNodes.map { sentinelNode -> NodeSelectionRowViewModel? in
            guard let node = sentinelNode.node else {
                return nil
            }
            
            let countryCode = CountryFormatter.code(for: node.info.location.country) ?? ""
            
            let flagImage: ImageAsset.Image?
#if os(iOS)
            flagImage = Flag(countryCode: countryCode)?.image(style: .roundedRect)
#elseif os(macOS)
            #warning("replace all the original images on macOS with rounded")
            flagImage = Flag(countryCode: countryCode)?.originalImage
#endif
            return NodeSelectionRowViewModel(
                from: node,
                icon: flagImage ?? Asset.Tokens.dvpn.image
            )
        }.compactMap { $0 }
        
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
    
    private func set(loadedNodesCount: Int) {
        self.loadedNodesCount = loadedNodesCount
        if loadedNodesCount >= self.nodes.count {
            self.isLoadingNodes = false
        }
    }
}
