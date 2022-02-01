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
            ContentView()
                .frame(minWidth: 1000, minHeight: 500)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem?.button?.image = NSImage(named: Asset.Navigation.sentinelBlack.name)
        
        statusItem?.menu = StatusMenu()
    }
}
