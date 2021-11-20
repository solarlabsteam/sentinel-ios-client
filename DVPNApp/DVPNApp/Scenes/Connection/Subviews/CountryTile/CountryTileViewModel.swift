//
//  CountryTileViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit
import SentinelWallet
import FlagKit

struct CountryTileViewModel: Hashable, Identifiable {
    let id: String
    let icon: UIImage
    let title: String?
    let subtitle: String
    let speedImage: UIImage?
    
    init(
        id: String,
        icon: UIImage,
        title: String?,
        subtitle: String,
        speed: UIImage?
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.speedImage = speed
    }

    init(from node: Node, icon: UIImage) {
        self.init(
            id: node.info.address,
            icon: icon,
            title: node.info.moniker,
            subtitle: String(node.info.address.suffix(6)),
            speed: node.info.bandwidth.speedImage
        )
    }
}
