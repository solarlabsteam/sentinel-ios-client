//
//  StoresNodes.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation
import SentinelWallet

protocol StoresNodes: AnyObject {
    var sentinelNodes: [SentinelNode] { get }
    func save(sentinelNodes: [SentinelNode])
    func save(node: Node, for sentinelNode: SentinelNode)
}
