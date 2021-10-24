//
//  NodesService.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

final class NodesService {
    private let nodesStorage: StoresNodes
    
    init(nodesStorage: StoresNodes) {
        self.nodesStorage = nodesStorage
    }
}

extension NodesService: NodesServiceType {
}
