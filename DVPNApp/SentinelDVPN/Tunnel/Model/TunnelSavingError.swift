//
//  SavingError.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

import Foundation

enum TunnelSavingError: Error {
    case nameRequired
    case privateKeyRequired
    case privateKeyInvalid
    case addressInvalid
    case listenPortInvalid
    case MTUInvalid

    case publicKeyRequired
    case publicKeyInvalid
    case preSharedKeyInvalid
    case allowedIPsInvalid
    case endpointInvalid
    case persistentKeepAliveInvalid

    case publicKeyDuplicated
}
