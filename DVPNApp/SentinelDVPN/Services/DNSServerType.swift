//
//  DNSServerType.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import Cocoa

enum DNSServerType: String, CaseIterable {
    case cloudflare
    case freenom
    case google
    case handshake

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
        return .cloudflare
    }
}
