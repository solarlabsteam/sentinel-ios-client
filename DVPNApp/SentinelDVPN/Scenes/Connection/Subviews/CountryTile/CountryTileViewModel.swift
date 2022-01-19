//
//  CountryTileViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SentinelWallet
import FlagKit

struct CountryTileViewModel: Hashable, Identifiable {
    let id: String
    let icon: ImageAsset.Image
    let title: String?
    let subtitle: String
    
    init(
        id: String,
        icon: ImageAsset.Image,
        title: String?,
        subtitle: String
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    init(from node: Node, icon: ImageAsset.Image) {
        self.init(
            id: node.info.address,
            icon: icon,
            title: node.info.moniker,
            subtitle: String(node.info.address.suffix(6))
        )
    }
}
