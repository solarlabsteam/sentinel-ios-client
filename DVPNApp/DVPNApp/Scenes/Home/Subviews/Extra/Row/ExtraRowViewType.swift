//
//  ExtraRowViewType.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

enum ExtraRowViewType {
    case dns(String)
    case more

    var image: Image {
        switch self {
        case .dns:
            return Image(uiImage: Asset.Extra.dns.image)
        case .more:
            return Image(uiImage: Asset.Extra.info.image)
        }
    }

    var title: String {
        switch self {
        case .dns:
            return L10n.Home.Extra.dns
        case .more:
            return L10n.Home.Extra.More.title
        }
    }

    var subtitle: String {
        switch self {
        case let .dns(servers):
            return servers
        case .more:
            return L10n.Home.Extra.More.subtitle
        }
    }
}
