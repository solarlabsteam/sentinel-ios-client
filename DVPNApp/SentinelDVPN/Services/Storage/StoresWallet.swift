//
//  StoresWallet.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

protocol StoresWallet {
    func set(wallet: String)
    func walletAddress() -> String?
}
