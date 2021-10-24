//
//  AutoRealmObject.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 21.10.2021.
//

import Foundation
import RealmSwift
import SentinelWallet

// MARK: - SentinelNodeObject
public class SentinelNodeObject: Object {
    @objc dynamic var address: String?
    @objc dynamic var provider: String?
    @objc dynamic var remoteURL: String?
    @objc dynamic var node: NodeObject?

    override public static func primaryKey() -> String? {
        return "address"
    }
}

// MARK: SentinelNode: Persistable
extension SentinelNode: Persistable {
    init(managedObject: SentinelNodeObject) {
        self.init(
            address: managedObject.address!,
            provider: managedObject.provider!,
            price: [],
            remoteURL: managedObject.remoteURL!,
            node: managedObject.node.flatMap { Node(managedObject: $0) } ?? nil
        )
    }
    
    func toManagedObject() -> SentinelNodeObject {
        let obj = SentinelNodeObject()
        
        obj.address = address
        obj.provider = provider
        obj.remoteURL = remoteURL
        obj.node = node?.toManagedObject()
        
        return obj
    }
}

// MARK: - NodeObject
public class NodeObject: Object {
    @objc dynamic var sentinelNode: SentinelNodeObject?
    @objc dynamic var info: DVPNNodeInfoObject?
    dynamic var latency: Double?

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: Node: Persistable
extension Node: Persistable {
    public init(managedObject: NodeObject) {
        self.init(
            info: DVPNNodeInfo(managedObject: managedObject.info!),
            latency: managedObject.latency ?? 0
        )
    }

    public func toManagedObject() -> NodeObject {
        let obj = NodeObject()
        
        obj.info = info.toManagedObject()
        obj.latency = latency

        return obj
    }
}

// MARK: - BandwidthObject
public class BandwidthObject: Object {
    let download = RealmProperty<Int?>()
    let upload = RealmProperty<Int?>()

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: Bandwidth: Persistable
extension Bandwidth: Persistable {
    public init(managedObject: BandwidthObject) {
        self.init(
            download: managedObject.download.value!,
            upload: managedObject.upload.value!
        )
    }

    public func toManagedObject() -> BandwidthObject {
        let obj = BandwidthObject()

        obj.download.value = download
        obj.upload.value = upload

        return obj
    }
}

// MARK: - DVPNNodeInfoObject
public class DVPNNodeInfoObject: Object {
    @objc dynamic var address: String?
    @objc dynamic var bandwidth: BandwidthObject?
    @objc dynamic var handshake: HandshakeObject?
    let intervalSetSessions = RealmProperty<Int?>()
    let intervalUpdateSessions = RealmProperty<Int?>()
    let intervalUpdateStatus = RealmProperty<Int?>()
    @objc dynamic var location: LocationObject?
    @objc dynamic var moniker: String?
    @objc dynamic var resultOperator: String?
    let peers = RealmProperty<Int?>()
    @objc dynamic var price: String?
    @objc dynamic var provider: String?
    @objc dynamic var qos: QOSObject?
    let type = RealmProperty<Int?>()
    @objc dynamic var version: String?

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: DVPNNodeInfo: Persistable
extension DVPNNodeInfo: Persistable {
    public init(managedObject: DVPNNodeInfoObject) {
        self.init(
            address: managedObject.address!,
            bandwidth: Bandwidth(managedObject: managedObject.bandwidth!),
            handshake: Handshake(managedObject: managedObject.handshake!),
            intervalSetSessions: managedObject.intervalSetSessions.value!,
            intervalUpdateSessions: managedObject.intervalUpdateSessions.value!,
            intervalUpdateStatus: managedObject.intervalUpdateStatus.value!,
            location: Location(managedObject: managedObject.location!),
            moniker: managedObject.moniker!,
            resultOperator: managedObject.resultOperator!,
            peers: managedObject.peers.value!,
            price: managedObject.price!,
            provider: managedObject.provider!,
            qos: managedObject.qos.flatMap { QOS(managedObject: $0) } ?? nil,
            type: managedObject.type.value!,
            version: managedObject.version!
        )
    }

    public func toManagedObject() -> DVPNNodeInfoObject {
        let obj = DVPNNodeInfoObject()

        obj.address = address
        obj.bandwidth = bandwidth.toManagedObject()
        obj.handshake = handshake.toManagedObject()
        obj.intervalSetSessions.value = intervalSetSessions
        obj.intervalUpdateSessions.value = intervalUpdateSessions
        obj.intervalUpdateStatus.value = intervalUpdateStatus
        obj.location = location.toManagedObject()
        obj.moniker = moniker
        obj.resultOperator = resultOperator
        obj.peers.value = peers
        obj.price = price
        obj.provider = provider
        obj.qos = qos?.toManagedObject()
        obj.type.value = type
        obj.version = version

        return obj
    }
}

// MARK: - HandshakeObject
public class HandshakeObject: Object {
    let enable = RealmProperty<Bool?>()
    let peers = RealmProperty<Int?>()

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: Handshake: Persistable
extension Handshake: Persistable {
    public init(managedObject: HandshakeObject) {
        self.init(
            enable: managedObject.enable.value!,
            peers: managedObject.peers.value!
        )
    }

    public func toManagedObject() -> HandshakeObject {
        let obj = HandshakeObject()

        obj.enable.value = enable
        obj.peers.value = peers

        return obj
    }
}

// MARK: - LocationObject
public class LocationObject: Object {
    @objc dynamic var city: String?
    @objc dynamic var country: String?

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: Location: Persistable
extension Location: Persistable {
    public init(managedObject: LocationObject) {
        self.init(
            city: managedObject.city!,
            country: managedObject.country!,
            latitude: 0,
            longitude: 0
        )
    }

    public func toManagedObject() -> LocationObject {
        let obj = LocationObject()

        obj.city = city
        obj.country = country

        return obj
    }
}

// MARK: - QOSObject
public class QOSObject: Object {
    let maxPeers = RealmProperty<Int?>()

    override public static func primaryKey() -> String? {
        return nil
    }
}

// MARK: QOS: Persistable
extension QOS: Persistable {
    public init(managedObject: QOSObject) {
        self.init(
            maxPeers: managedObject.maxPeers.value!
        )
    }

    public func toManagedObject() -> QOSObject {
        let obj = QOSObject()

        obj.maxPeers.value = maxPeers

        return obj
    }
}
