//
//  Persistable.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import Realm
import RealmSwift

protocol Persistable {
    associatedtype ManagedObject: RLMObjectBase
    
    static var managedObjectType: ManagedObject.Type { get }
    
    init(managedObject: ManagedObject)

    func toManagedObject() -> ManagedObject
}

extension Persistable {
    static var managedObjectType: ManagedObject.Type {
        return ManagedObject.self
    }
}

protocol Preservable: Persistable where ManagedObject: Object {
}
