//
//  Persistable.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import RealmSwift

protocol Persistable {
    associatedtype ManagedObject: Object
    
    static var managedObjectType: ManagedObject.Type { get }
    
    init(managedObject: ManagedObject)

    func toManagedObject() -> ManagedObject
}

extension Persistable {
    static var managedObjectType: ManagedObject.Type {
        return ManagedObject.self
    }
}
