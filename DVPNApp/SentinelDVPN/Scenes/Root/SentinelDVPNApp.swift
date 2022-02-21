//
//  SentinelDVPNApp.swift
//  SentinelDVPN
//
//  Created by Viktoriia Kostyleva on 18.01.2022.
//

import SwiftUI

@main
struct SentinelDVPNApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ModulesFactory.shared.detectStartModule()
                .frame(minWidth: 1000, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Hide Services from SentinelDVPN command tab
            CommandGroup(replacing: .systemServices) {}
            
            CommandGroup(replacing: .undoRedo) {}
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem?.button?.image = NSImage(named: Asset.Navigation.sentinelBlack.name)
        
        statusItem?.menu = ModulesFactory.shared.makeStatusMenu()
    }
}
