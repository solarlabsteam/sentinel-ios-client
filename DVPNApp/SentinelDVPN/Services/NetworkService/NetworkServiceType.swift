//
//  NetworkServiceType.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 29.09.2021.
//

import Foundation
import WireGuardKit

protocol NetworkServiceType {
    func fetchConnectionData(
        remoteURLString: String,
        id: UInt64,
        accountAddress: String,
        signature: String,
        completion: @escaping (Result<(Data, PrivateKey), Error>) -> Void
    )

    func fetchIP(completion: @escaping (String) -> Void)
}
