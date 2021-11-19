import UIKit
import SentinelWallet
import FlagKit

struct NodeSelectionRowViewModel: Hashable, Identifiable {
    let id: String
    let icon: UIImage
    let title: String
    let subtitle: String
    
    let latency: Int
    
    init(
        id: String,
        icon: UIImage,
        title: String,
        subtitle: String,
        latency: Int
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.latency = latency
    }

    init(from node: Node, icon: UIImage) {
        self.init(
            id: node.info.address,
            icon: icon,
            title: node.info.moniker,
            subtitle: String(node.info.address.suffix(6)),
            latency: Int((node.latency.truncatingRemainder(dividingBy: 1)) * 1000)
        )
    }
}
