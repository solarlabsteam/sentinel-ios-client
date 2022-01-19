//
//  NodeSelectionRowViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SentinelWallet
import FlagKit

struct NodeSelectionRowViewModel: Hashable, Identifiable {
    let id: String

    let icon: ImageAsset.Image
    let title: String
    let subtitle: String

    let speed: ImageAsset.Image

    let price: Int
    let peers: Int
    /// in ms
    let latency: Int
    
    var scales: [ScaleViewType] {
        [.price(price), .peers(peers), .latency(latency)]
    }
    
    init(
        id: String,
        icon: ImageAsset.Image,
        title: String,
        subtitle: String,
        price: Int,
        speed: ImageAsset.Image,
        latency: Int,
        peers: Int
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle

        self.speed = speed

        self.price = price
        self.latency = latency
        self.peers = peers
    }

    init(from node: Node, icon: ImageAsset.Image) {
        let price = PriceFormatter.rawFormat(price: node.info.price).price
        
        self.init(
            id: node.info.address,
            icon: icon,
            title: node.info.moniker,
            subtitle: String(node.info.address.suffix(6)),
            price: price,
            speed: node.info.bandwidth.speedImage,
            latency: Int((node.latency.truncatingRemainder(dividingBy: 1)) * 1000),
            peers: node.info.peers
        )
    }
}
