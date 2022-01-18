//
//  StoresGeneralInfo.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

protocol StoresGeneralInfo {
    func set(didPassOnboarding: Bool)
    func didPassOnboarding() -> Bool
}
