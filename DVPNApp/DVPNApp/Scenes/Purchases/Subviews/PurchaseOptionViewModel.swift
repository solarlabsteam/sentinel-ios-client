//
//  PurchaseOptionViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 22.11.2021.
//

import Foundation
import RevenueCat

struct PurchaseOptionViewModel: Hashable {
    let package: Package
    let amount: Int
    let price: String

    var bandwidth: String {
        "~ \(amount / 2) GB"
    }

    var isSelected: Bool
}
