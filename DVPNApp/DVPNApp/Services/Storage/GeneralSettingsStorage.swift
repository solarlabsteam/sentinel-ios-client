//
//  GeneralSettingsStorage.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 18.08.2021.
//

import Foundation

private struct Constants {
    let defaultDNS = "10.8.0.1"
}

private let constants = Constants()

private enum Keys: String {
    case needOpenPlans
    case shouldConnect
    case didPassOnboarding

    case lastSelectedNodeKey
    case walletKey
    case lastSessionKey
    case dnsKey
}

final class GeneralSettingsStorage {
    private let settingsStorageStrategy: SettingsStorageStrategyType

    init(settingsStorageStrategy: SettingsStorageStrategyType) {
        self.settingsStorageStrategy = settingsStorageStrategy
    }

    func set(didPassOnboarding: Bool) {
        settingsStorageStrategy.setObject(didPassOnboarding, forKey: Keys.didPassOnboarding.rawValue)
    }

    func didPassOnboarding() -> Bool {
        settingsStorageStrategy.object(ofType: Bool.self, forKey: Keys.didPassOnboarding.rawValue) ?? false
    }

    func set(shouldConnect: Bool) {
        settingsStorageStrategy.setObject(shouldConnect, forKey: Keys.shouldConnect.rawValue)
    }

    func shouldConnect() -> Bool {
        settingsStorageStrategy.object(ofType: Bool.self, forKey: Keys.shouldConnect.rawValue) ?? false
    }
    
    func set(lastSelectedNode: String) {
        settingsStorageStrategy.setObject(lastSelectedNode, forKey: Keys.lastSelectedNodeKey.rawValue)
    }

    func lastSelectedNode() -> String? {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.lastSelectedNodeKey.rawValue)
    }

    func set(wallet: String) {
        settingsStorageStrategy.setObject(wallet, forKey: Keys.walletKey.rawValue)
    }

    func walletAddress() -> String? {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.walletKey.rawValue)
    }

    func set(sessionId: Int?) {
        settingsStorageStrategy.setObject(sessionId, forKey: Keys.lastSessionKey.rawValue)
    }

    func lastSessionId() -> Int? {
        settingsStorageStrategy.object(ofType: Int.self, forKey: Keys.lastSessionKey.rawValue)
    }

    func set(dns: String) {
        settingsStorageStrategy.setObject(dns, forKey: Keys.dnsKey.rawValue)
    }

    func selectedDNS() -> String {
        settingsStorageStrategy.object(ofType: String.self, forKey: Keys.dnsKey.rawValue) ?? constants.defaultDNS
    }
}
