import UIKit
import SentinelWallet
import FlagKit

struct NodeSelectionRowViewModel: Hashable, Identifiable {
    let id: String

    let icon: UIImage
    let title: String
    let subtitle: String

    let speed: UIImage

    let price: Double
    let peers: Double
    let latency: Double

    var scales: [ScaleViewType] {
        [.price(price), .peers(peers), .latency(latency)]
    }
    
    init(
        id: String,
        icon: UIImage,
        title: String,
        subtitle: String,
        price: Double,
        speed: UIImage,
        latency: Double,
        peers: Double
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

    init(from node: Node, icon: UIImage) {
        let price = PriceFormatter.rawFormat(price: node.info.price).price.pricePersentage
        self.init(
            id: node.info.address,
            icon: icon,
            title: node.info.moniker,
            subtitle: String(node.info.address.suffix(6)),
            price: price,
            speed: node.info.bandwidth.speedImage,
            latency: node.latency.latencyPercentage,
            peers: 1 - Double(node.info.peers) / Double(node.info.qos?.maxPeers ?? 100)
        )
    }
}
