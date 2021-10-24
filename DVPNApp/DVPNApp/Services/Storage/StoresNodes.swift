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
    func saveSentinelNodes(_ sentinelNodes: [SentinelNode])
    func saveNode(_ node: Node, for sentinelNode: SentinelNode)
}
