//
//  AvailableNodesViewModel.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import Cocoa
import FlagKit
import SentinelWallet
import Combine
import AlertToast

final class AvailableNodesViewModel: ObservableObject {
    @Published private(set) var locations: [NodeSelectionRowViewModel] = []
    @Published var selectedType: NodesColumnState = .all
    
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
    
    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    
    @Published var showPlansSheet = false {
        didSet {
            if showPlansSheet == false {
                nodeToToggle = nil
            }
        }
    }
    
    @Published var nodeToToggle: Node?

    init(continent: Continent, model: AvailableNodesModel) {
        self.continent = continent
        self.model = model

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
            isLoadingNodes = true
        }
    }
}

// MARK: - Buttons actions

extension AvailableNodesViewModel {
    func toggleLocation(with id: String) {
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address == id }),
              let node = sentinelNode.node else {
                  show(error: NodeSelectionViewModelError.unavailableNode)
                  return
              }
        
        toggle(node: node)
    }
    
    func openDetails(for id: String) {
        guard let sentinelNode = nodes.first(where: { $0.node?.info.address == id }) else {
            show(error: NodeSelectionViewModelError.unavailableNode)
            return
        }
        
        let isSubscribed = model.isSubscribed(to: sentinelNode.address)
        
        selectedType = .details(sentinelNode, isSubscribed: isSubscribed)
    }

    func closeDetails() {
        selectedType = .all
    }
}

// MARK: - Private

extension AvailableNodesViewModel {
    private func show(error: Error) {
        alertContent = (
            true,
            AlertToast(type: .error(NSColor.systemRed.asColor), title: error.localizedDescription)
        )
    }

    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .update(nodes):
                    self?.update(nodes: Set(nodes))
                case let .setLoadedNodesCount(loadedNodesCount):
                    self?.set(loadedNodesCount: loadedNodesCount)
                case let .allLoaded(isAllLoaded):
                    self?.isAllLoaded = isAllLoaded
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
            
            let flagImage = Flag(countryCode: countryCode)?.originalImage
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
            showPlansSheet = true
            nodeToToggle = node
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
