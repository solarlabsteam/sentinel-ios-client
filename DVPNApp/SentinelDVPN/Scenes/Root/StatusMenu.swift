//
//  StatusMenu.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 31.01.2022.
//

import SwiftUI
import FlagKit

class StatusMenu: NSMenu {
    init() {
        super.init(title: "Status Bar Menu")
        
        addNodeMenuItems()
        addConnectionMenuItems()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatusMenu {
    // MARK: - Node item
    
    func addNodeMenuItems() {
        let nodeInfoItem = NSMenuItem()
        nodeInfoItem.title = "test Russia vpn"
        nodeInfoItem.image = Flag(countryCode: "RU")?.originalImage
        
        addItem(nodeInfoItem)
    }
    
    // MARK: - Connection item
    
    func addConnectionMenuItems() {
        let currentStatusItem = NSMenuItem()
        currentStatusItem.title = "Status: disconnected"
        
        addItem(currentStatusItem)
        
        addItem(NSMenuItem.separator())
        
        let connectionMenuItem = NSMenuItem(
            title: "Connect", action: #selector(toggleConnection), keyEquivalent: ""
        )
        connectionMenuItem.target = self
        addItem(connectionMenuItem)
    }
    
    @objc
    func toggleConnection() {
        print("toggle connection")
    }
}
