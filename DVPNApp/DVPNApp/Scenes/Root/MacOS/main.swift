//
//  main.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
