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
    case duration
}

// MARK: - ConnectionInfoType

extension ConnectionInfoType {
    var icon: UIImage {
        switch self {
        case .download:
            return Asset.Icons.downArrow.image
        case .upload:
            return Asset.Icons.upArrow.image
        case .bandwidth:
            return Asset.Icons.bandwidth.image
        case .duration:
            return Asset.Icons.duration.image
        }
    }
    
    // TODO: Localize
    var title: String {
        switch self {
        case .download:
            return "Download"
        case .upload:
            return "Upload"
        case .bandwidth:
            return "Bandwidth"
        case .duration:
            return "Duration"
        }
    }
}

// MARK: - IconSide

enum IconSide {
    case left
    case right
}
