//
//  RealmStorage+Ext.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import RealmSwift
import Realm

extension RealmStorage {
    func save<T: Persistable>(object: T) throws {
        if T.ManagedObject.primaryKey() != nil {
            realm.add(object.toManagedObject(), update: .modified)
        } else {
            realm.add(object.toManagedObject())
        }
    }
    
    func save<T: Collection>(collection: T) throws where T.Element: Persistable {
        if T.Element.managedObjectType.primaryKey() != nil {
            realm.add(collection.map { $0.toManagedObject() }, update: .modified)
        } else {
            realm.add(collection.map { $0.toManagedObject() })
        }
    }
}

// MARK: - Realm safe write

extension Realm {
    func safeWrite(
        withoutNotifyingIfIsNotInWriteTransaction withoutNotifying: [RealmSwift.NotificationToken] = [],
        _ block: (() throws -> Void)
    ) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(withoutNotifying: withoutNotifying, block)
        }
    }
}
