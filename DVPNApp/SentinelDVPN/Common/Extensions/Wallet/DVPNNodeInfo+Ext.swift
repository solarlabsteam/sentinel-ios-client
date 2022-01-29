//
//  DVPNNodeInfo+Ext.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 12.08.2021.
//

import Foundation
import SentinelWallet
import Cocoa

extension Node: Hashable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.info.address == rhs.info.address
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(info.address)
    }
}

extension Bandwidth {
    var averageSpeedPercentage: Double {
        (Int64(upload + download) / 2).bandwidthMB / 40
    }

    var speedImage: ImageAsset.Image {
        let avg = averageSpeedPercentage
        if avg < 0.25 {
            return Asset.Connection.Wifi.scales1.image
        }
        if avg < 0.5 {
            return Asset.Connection.Wifi.scales2.image
        }
        if avg < 0.75 {
            return Asset.Connection.Wifi.scales3.image
        }

        return Asset.Connection.Wifi.scales4.image
    }
}

extension TimeInterval {
    var latencyPercentage: Double {
        let raw = self / 2
        if raw > 1 { return 0 }
        if raw < 0 { return 1 }
        return 1 - raw
    }
}
