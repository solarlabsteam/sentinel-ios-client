//
//  RealmStorage.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import RealmSwift

final class RealmStorage {
    private(set) var realm: Realm
    
    private init(realm: Realm) {
        self.realm = realm
    }
    
    convenience init?() {
        do {
            let realm = try Realm()
            self.init(realm: realm)
        } catch {
            log.error("Failed to init Realm: \(error)")
            return nil
        }
    }
    
    static func prepare() {
        let currentSchemaVersion: UInt64 = 1
        
        let config = Realm.Configuration(
            schemaVersion: currentSchemaVersion,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in }
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        let urlString = config.fileURL.map { String(describing: $0) } ?? "nil"
        log.info("Local URL of the Realm file: \(urlString)")
    }
}

// MARK: - Migrations

enum RealmMigrator {}
