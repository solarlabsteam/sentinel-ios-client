//
//  Double+Ext.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 20.10.2021.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
