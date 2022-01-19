//
//  ConnectionStatus.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 16.09.2021.
//

import Foundation
import SwiftUI

enum ConnectionStatus {
    case connected
    case sessionStatus
    case nodeStatus
    case subscriptionStatus
    case balanceCheck
    case sessionBroadcast
    case keysExchange
    case tunnelUpdating
    case disconnected

    init(from value: Bool) {
        self = value ? .connected : .disconnected
    }

    var title: String {
        switch self {
        case .connected:
            return L10n.Connection.Status.Connection.connected
        case .sessionStatus:
            return L10n.Connection.Status.Connection.sessionStatus
        case .nodeStatus:
            return L10n.Connection.Status.Connection.nodeStatus
        case .subscriptionStatus:
            return L10n.Connection.Status.Connection.subscriptionStatus
        case .balanceCheck:
            return L10n.Connection.Status.Connection.balanceCheck
        case .sessionBroadcast:
            return L10n.Connection.Status.Connection.sessionBroadcast
        case .keysExchange:
            return L10n.Connection.Status.Connection.keysExchange
        case .tunnelUpdating:
            return L10n.Connection.Status.Connection.tunnelUpdating
        case .disconnected:
            return L10n.Connection.Status.Connection.disconnected
        }
    }

    var color: Color {
        switch self {
        case .connected:
            return .green
        case .disconnected:
            return .red
        default:
            return .blue
        }
    }

    var isLoading: Bool {
        !(self == .connected || self == .disconnected)
    }
}
