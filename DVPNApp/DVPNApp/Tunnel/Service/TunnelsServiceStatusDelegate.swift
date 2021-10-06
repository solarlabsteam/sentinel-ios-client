//
//  TunnelsServiceStatusDelegate.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

import Foundation
import WireGuardKit

enum TunnelsServiceError: Error {
    case emptyName
    case nameAlreadyExists

    case loadTunnelsFailed(systemError: Error)
    case addTunnelFailed(systemError: Error)
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
