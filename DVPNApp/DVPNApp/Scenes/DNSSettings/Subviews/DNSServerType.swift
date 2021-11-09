//
//  DNSServerType.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

enum DNSServerType: String, CaseIterable {
    case cloudflare
    case freenom
    case google
    case handshake

    var title: String {
        switch self {
        case .cloudflare:
            return L10n.Dns.cloudflare
        case .google:
            return L10n.Dns.google
        case .freenom:
            return L10n.Dns.freenom
        case .handshake:
            return L10n.Dns.handshake
        }
    }
    
    var image: ImageAsset.Image {
        switch self {
        case .cloudflare:
            return Asset.Dns.cloudflare.image
        case .google:
            return Asset.Dns.google.image
        case .freenom:
            return Asset.Dns.freenom.image
        case .handshake:
            return Asset.Dns.handshake.image
        }
    }

    var address: String {
        switch self {
        case .cloudflare:
            return "1.1.1.1, 1.0.0.1"
        case .google:
            return "8.8.8.8, 8.8.4.4"
        case .freenom:
            return "80.80.80.80, 80.80.81.81"
        case .handshake:
            return "103.196.38.38, 103.196.38.39"
        }
    }

    static var `default`: DNSServerType {
        return .handshake
    }
}
