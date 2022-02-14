//
//  ConnectionMenuService.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 01.02.2022.
//

import Foundation

final class ConnectionMenuService {
    // Location Selector
    @Published var countryName: String?
    @Published var moniker: String = "No country"
    
    // Connection Status
    @Published var isConnected: Bool = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    @Published var toggleConnectionNewState: Bool = false 
    
    init() {
    }
}
