//
//  NodeInfoType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit

enum NodeInfoType {
    case address
    case peers
    case uploadSpeed
    case provider
    case downloadSpeed
    case version
    case type
    case country
    case city
    case features
}

extension NodeInfoType {
    var icon: UIImage {
        switch self {
        case .address:
            return Asset.Node.wiFi.image
        case .peers:
            return Asset.Node.peers.image
        case .uploadSpeed:
            return Asset.Node.upload.image
        case .provider:
            return Asset.Node.provider.image
        case .downloadSpeed:
            return Asset.Node.download.image
        case .version:
            return Asset.Node.version.image
        case .type:
            return Asset.Node.type.image
        case .country:
            return Asset.Node.country.image
        case .city:
            return Asset.Node.city.image
        case .features:
            return UIImage()
        }
    }
    
    var title: String {
        switch self {
        case .address:
            return L10n.NodeDetails.InfoType.address
        case .peers:
            return L10n.NodeDetails.InfoType.peers
        case .uploadSpeed:
            return L10n.NodeDetails.InfoType.uploadSpeed
        case .provider:
            return L10n.NodeDetails.InfoType.provider
        case .downloadSpeed:
            return L10n.NodeDetails.InfoType.downloadSpeed
        case .version:
            return L10n.NodeDetails.InfoType.version
        case .type:
            return L10n.NodeDetails.InfoType.typeOfNode
        case .country:
            return L10n.NodeDetails.InfoType.country
        case .city:
            return L10n.NodeDetails.InfoType.city
        case .features:
            return L10n.NodeDetails.InfoType.features
        }
    }
}
