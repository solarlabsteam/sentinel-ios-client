//
//  ConnectionInfoType.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit

enum ConnectionInfoType {
    case download
    case upload
    case bandwidth
    case consumed
    case duration
}

// MARK: - ConnectionInfoType

extension ConnectionInfoType {
    var icon: UIImage? {
        switch self {
        case .download:
            return Asset.Icons.downArrow.image
        case .upload:
            return Asset.Icons.upArrow.image
        case .bandwidth:
            return nil
        case .consumed:
            return nil
        case .duration:
            return Asset.Icons.duration.image
        }
    }
    
    var title: String {
        switch self {
        case .download:
            return L10n.Connection.InfoType.download
        case .upload:
            return L10n.Connection.InfoType.upload
        case .bandwidth:
            return L10n.Connection.InfoType.bandwidth
        case .consumed:
            return L10n.Connection.InfoType.consumed
        case .duration:
            return L10n.Connection.InfoType.duration
        }
    }
}
