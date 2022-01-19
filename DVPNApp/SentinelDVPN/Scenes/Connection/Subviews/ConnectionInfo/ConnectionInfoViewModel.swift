//
//  ConnectionInfoViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Foundation

struct ConnectionInfoViewModel: Hashable {
    let id: String
    let type: ConnectionInfoType
    let value: String
    let symbols: String?
    
    init(
        type: ConnectionInfoType,
        value: String,
        symbols: String?
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
        self.symbols = symbols
    }
}
