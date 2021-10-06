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
            // TODO: nil?
            return UIImage()
        }
    }

    // TODO: Localize
    var title: String {
        switch self {
        case .address:
            return "Node Address"
        case .peers:
            return "Connected peers count"
        case .uploadSpeed:
            return "Upload speed"
        case .provider:
            return "Node provider"
        case .downloadSpeed:
            return "Download speed"
        case .version:
            return "Version"
        case .type:
            return "Type of Node"
        case .country:
            return "Country"
        case .city:
            return "City"
        case .features:
            return "Features"
        }
    }
}
