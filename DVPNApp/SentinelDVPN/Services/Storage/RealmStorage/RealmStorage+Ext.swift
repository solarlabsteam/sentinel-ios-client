//
//  RealmStorage+Ext.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import RealmSwift
import Realm

extension RealmStorage {
    func save<T: Preservable>(object: T, to realm: Realm) {
        guard T.ManagedObject.primaryKey() == nil else {
            realm.add(object.toManagedObject(), update: .modified)
            return
        }
        
        realm.add(object.toManagedObject())
    }
    
    func save<T: Collection>(collection: T, to realm: Realm) where T.Element: Preservable {
        guard T.Element.managedObjectType.primaryKey() == nil else {
            realm.add(collection.map { $0.toManagedObject() }, update: .modified)
            return
        }
        
        realm.add(collection.map { $0.toManagedObject() })
    }
    
    func delete<Entity: Preservable>(_ entity: Entity, from realm: Realm) {
        realm.delete(entity.toManagedObject())
    }
}

// MARK: - Realm safe write

extension Realm {
    func safeWrite(
        withoutNotifying: [RealmSwift.NotificationToken] = [],
        _ block: (() throws -> Void)
    ) throws {
        guard isInWriteTransaction else {
            try write(withoutNotifying: withoutNotifying, block)
            return
        }
        
        try block()
    }
}
