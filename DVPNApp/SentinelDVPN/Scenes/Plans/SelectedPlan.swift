//
//  SelectedPlan.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 16.08.2021.
//

import Foundation
import SentinelWallet

struct SelectedPlan {
    let node: DVPNNodeInfo
    let deposit: CoinToken

    let planString: String
    let price: String
}
