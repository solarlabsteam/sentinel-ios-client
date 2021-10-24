//
//  StoresDNSServers.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

protocol StoresDNSServers {
    func set(dns: DNSServerType)
    func selectedDNS() -> DNSServerType
}
