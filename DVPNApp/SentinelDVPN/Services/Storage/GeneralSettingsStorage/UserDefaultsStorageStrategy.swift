//
//  StorageService.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 18.08.2021.
//

import Foundation

import Foundation

final class UserDefaultsStorageStrategy {
    private let defaults = UserDefaults.standard
}

// MARK: SettingsStorageStrategyType implementation

extension UserDefaultsStorageStrategy: SettingsStorageStrategyType {
    func object<T: Codable>(ofType type: T.Type, forKey key: String) -> T? {
        if let data = defaults.value(forKey: key) as? Data,
            let object = Serializer.fromData(data, withType: type.self) {
            return object
        }
        return nil
    }

    func setObject<T: Codable>(_ object: T, forKey key: String) -> Bool {
        if let encoded = Serializer.toData(from: object) {
            defaults.set(encoded, forKey: key)
            return true
        }
        return false
    }

    func existsObject(forKey key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }

    func removeObject(forKey key: String) -> Bool {
        defaults.set(nil, forKey: key)
        return true
    }
}
