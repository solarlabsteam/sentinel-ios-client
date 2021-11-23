//
//  PurchaseOptionViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 22.11.2021.
//

import Foundation

struct PurchaseOptionViewModel: Hashable {
    var amount: Int
    var price: String

    var bandwidth: String {
        "~ \(amount / 2) GB"
    }

    var isSelected: Bool
}
