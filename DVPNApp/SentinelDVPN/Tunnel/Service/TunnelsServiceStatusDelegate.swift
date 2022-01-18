//
//  TunnelsServiceStatusDelegate.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

import Foundation
import WireGuardKit

enum TunnelsServiceError: LocalizedError {
    case emptyName
    case nameAlreadyExists

    case loadTunnelsFailed(systemError: Error)
    case addTunnelFailed(systemError: Error)
}

extension TunnelsServiceError {
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            return "The name of tunnel is empty"
        case .nameAlreadyExists:
            return "The name of tunnel already exist"
        case .loadTunnelsFailed:
            return L10n.Home.Node.Subscribed.noConnection
        case .addTunnelFailed:
            return L10n.Error.tunnelCreationDenied
        }
    }
}

enum TunnelActivationError: Error {
    case inactive
    case startingFailed(systemError: Error)
    case savingFailed(systemError: Error)
    case loadingFailed(systemError: Error)
    case retryLimitReached(lastSystemError: Error)
    case activationAttemptFailed(wasOnDemandEnabled: Bool)
}

protocol TunnelsServiceStatusDelegate: AnyObject {
    func activationAttemptFailed(for tunnel: TunnelContainer, with error: TunnelActivationError)
    func activationAttemptSucceeded(for tunnel: TunnelContainer)

    func activationFailed(for tunnel: TunnelContainer, with error: TunnelActivationError)
    func activationSucceeded(for tunnel: TunnelContainer)

    func deactivationSucceeded(for tunnel: TunnelContainer)
}
