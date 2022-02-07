//
//  NodeDetailsViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Cocoa
import FlagKit
import SentinelWallet
import Combine
import AlertToast

final class NodeDetailsViewModel: ObservableObject {
    private let model: NodeDetailsModel

    @Published private(set) var countryTileModel: CountryTileViewModel?
    @Published private(set) var nodeInfoViewModels: [NodeInfoViewModel] = []
    
    @Published private(set) var node: Node?
    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    
    @Published var showPlansPopover = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: NodeDetailsModel) {
        self.model = model

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .update(node):
                    self?.update(sentinelNode: node)
                }
            }
            .store(in: &cancellables)
        
        model.refresh()
    }
}

extension NodeDetailsViewModel {
    func update(sentinelNode: SentinelNode) {
        self.node = sentinelNode.node
        
        guard let node = node else {
            return
        }
        
        let nodeInfo = node.info
        
        let countryCode = CountryFormatter.code(for: nodeInfo.location.country) ?? ""
        let flagImage: ImageAsset.Image?

        #warning("replace all the original images on macOS with rounded")
        flagImage = Flag(countryCode: countryCode)?.originalImage
        
        countryTileModel = .init(
            id: "0",
            icon: flagImage ?? Asset.Tokens.dvpn.image,
            title: nodeInfo.moniker,
            subtitle: String(nodeInfo.address.suffix(6))
        )
        
        let domain = URL(string: sentinelNode.remoteURL)?.host ?? ""
        let upload = nodeInfo.bandwidth.upload.getBandwidthKBorMB
        let download = nodeInfo.bandwidth.download.getBandwidthKBorMB
        
        nodeInfoViewModels = [
            NodeInfoViewModel(type: .address, value: domain),
            NodeInfoViewModel(type: .peers, value: "\(nodeInfo.peers)"),
            NodeInfoViewModel(type: .uploadSpeed, value: makeString(from: upload)),
            NodeInfoViewModel(type: .provider, value: "Unknown"),
            NodeInfoViewModel(type: .downloadSpeed, value: makeString(from: download)),
            NodeInfoViewModel(type: .version, value: nodeInfo.version),
            NodeInfoViewModel(type: .type, value: "Wireguard"),
            NodeInfoViewModel(type: .country, value: nodeInfo.location.country),
            NodeInfoViewModel(type: .city, value: nodeInfo.location.city),
            NodeInfoViewModel(type: .features, value: "")
        ]
    }
    
    var gridViewModels: [GridViewModelType] {
        nodeInfoViewModels.map { GridViewModelType.nodeInfo($0) }
    }
}

// MARK: - Buttons actions

extension NodeDetailsViewModel {
    func didTapConnect() {
        guard let node = node else { return }
        toggle(node: node)
    }
}

// MARK: - Private

extension NodeDetailsViewModel {
    private func show(error: Error) {
        alertContent = (
            true,
            AlertToast(type: .error(NSColor.systemRed.asColor), title: error.localizedDescription)
        )
    }

    private func toggle(node: Node) {
        guard model.isSubscribed else {
            showPlansPopover = true
            return
        }
        
        model.save(nodeAddress: node.info.address)
    }
    
    private func makeString(from tuple: (String, String)) -> String {
        return tuple.0 + " " + tuple.1
    }
}
