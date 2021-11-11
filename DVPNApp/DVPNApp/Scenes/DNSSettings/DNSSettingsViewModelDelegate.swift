//
//  DNSSettingsViewModelDelegate.swift
//  DVPNApp
//
//  Created by Viktoriia Kostyleva on 11.11.2021.
//

protocol DNSSettingsViewModelDelegate: AnyObject {
    func update(to server: DNSServerType)
}
