//
//  NodeInfoViewModel.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import Foundation

struct NodeInfoViewModel: Hashable {
    let id: String
    let type: NodeInfoType
    let value: String
    
    init(
        type: NodeInfoType,
        value: String
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.value = value
    }
}
