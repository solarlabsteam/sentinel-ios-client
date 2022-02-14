//
//  StatusMenu.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 31.01.2022.
//

import SwiftUI
import FlagKit
import Combine

class StatusMenu: NSMenu {
    typealias Context = HasConnectionMenuService
    private let context: Context
    
    private var cancellables = Set<AnyCancellable>()
    
    private let nodeInfoItem = NSMenuItem()
    private let currentStatusItem = NSMenuItem()
    private let connectionMenuItem = NSMenuItem(
        title: "", action: #selector(toggleConnection), keyEquivalent: ""
    )
        
    init(context: Context) {
        self.context = context
        
        super.init(title: "Status Bar Menu")
        
        subscribeToEvents()
        addMenuItems()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatusMenu {
    private func subscribeToEvents() {
        context.connectionMenuService.$countryName
            .sink(receiveValue: { [weak self] countryName in
                if let countryName = countryName,
                   let countryCode = CountryFormatter.code(for: countryName),
                   let image = Flag(countryCode: countryCode)?.originalImage {
                    self?.nodeInfoItem.image = image
                }
            }).store(in: &cancellables)
        
        context.connectionMenuService.$moniker
            .sink(receiveValue: { value in
                self.nodeInfoItem.title = value
            }).store(in: &cancellables)
        
        context.connectionMenuService.$isConnected
            .sink(receiveValue: { isConnected in
                self.connectionMenuItem.title = isConnected ? L10n.Menu.Connection.disconnect
                : L10n.Menu.Connection.connect
            }).store(in: &cancellables)
        
        context.connectionMenuService.$connectionStatus
            .sink(receiveValue: { connectionStatus in
                self.currentStatusItem.title = L10n.Menu.Connection.status(connectionStatus.title)
            }).store(in: &cancellables)
    }
    
    private func addMenuItems() {
        connectionMenuItem.target = self
        
        addItem(nodeInfoItem)
        addItem(currentStatusItem)
        addItem(NSMenuItem.separator())
        addItem(connectionMenuItem)
    }
    
    @objc
    func toggleConnection() {
        context.connectionMenuService.toggleConnectionNewState = !context.connectionMenuService.isConnected
    }
}
