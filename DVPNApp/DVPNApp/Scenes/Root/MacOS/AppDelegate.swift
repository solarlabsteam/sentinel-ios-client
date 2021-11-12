//
//  AppDelegate.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Config.setup()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 880),
            styleMask: [.miniaturizable, .closable, .titled],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Sentinel DVPN"
        ModulesFactory.shared.detectStartModule(for: window)
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
