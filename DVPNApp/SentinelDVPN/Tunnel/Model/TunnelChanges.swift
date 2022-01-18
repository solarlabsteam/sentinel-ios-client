//
//  TunnelChanges.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

import Foundation

struct Changes {
    enum FieldChange: Equatable {
        case added
        case removed
        case modified(newValue: String)
    }

    var interfaceChanges: [TunnelInterfaceField: FieldChange]
    var peerChanges: [(peerIndex: Int, changes: [PeerField: FieldChange])]
    var peersRemovedIndices: [Int]
    var peersInsertedIndices: [Int]
}
