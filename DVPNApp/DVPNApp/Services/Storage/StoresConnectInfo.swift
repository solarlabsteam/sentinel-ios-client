//
//  StoresConnectInfo.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.10.2021.
//

import Foundation

protocol StoresConnectInfo {
    func set(shouldConnect: Bool)
    func shouldConnect() -> Bool
    func set(lastSelectedNode: String)
    func lastSelectedNode() -> String?
    func set(sessionId: Int?)
    func lastSessionId() -> Int?
    func set(sessionStart: Date?)
    func lastSessionStart() -> Date?
}
