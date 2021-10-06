//
//  GRPCError+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 26.08.2021.
//

import Foundation
import GRPC

extension GRPCError.RPCTimedOut: LocalizedError {
    public var errorDescription: String? {
        L10n.Error.GRPCError.rpcTimedOut
    }
}
