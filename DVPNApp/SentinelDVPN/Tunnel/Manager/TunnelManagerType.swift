//
//  TunnelManagerType.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 30.09.2021.
//

import Foundation
import WireGuardKit

typealias TunnelManagerTypeDelegate = TunnelManagerDelegate & TunnelsServiceStatusDelegate

protocol TunnelManagerType: AnyObject {
    var delegate: TunnelManagerTypeDelegate? { get set }
    
    var lastTunnel: TunnelContainer? { get }
    
    var isTunnelActive: Bool { get }
    
    func prepareTunnelModel()
    
    @discardableResult
    func startDeactivationOfActiveTunnel() -> Bool
    
    func startActivation(of tunnel: TunnelContainer)
    
    func startDeactivation(of tunnel: TunnelContainer)
    
    func createNewProfile(
        from data: Data,
        with privateKey: PrivateKey
    )
    
    func update(with server: String)
}
