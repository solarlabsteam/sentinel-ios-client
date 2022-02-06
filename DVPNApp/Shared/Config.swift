//
//  Config.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

import SwiftyBeaver

let log = SwiftyBeaver.self

public struct Config {
    static func setup() {
        LogsConfig.setupConsole()
        LogsConfig.setupFile()
    }
}

struct LogsConfig {
    static func setupConsole() {
        let console = ConsoleDestination()
        setup(destination: console)
        log.addDestination(console)
    }

    static func setupFile() {
        let file = FileDestination()
        setup(destination: file)
        log.addDestination(file)
    }

    private static func setup(destination: BaseDestination) {
        destination.levelColor.verbose = "📓 "
        destination.levelColor.debug = "📗 "
        destination.levelColor.info = "📘 "
        destination.levelColor.warning = "📒 "
        destination.levelColor.error = "📕 "
        #if DEBUG
        destination.minLevel = .verbose
        #else
        destination.minLevel = .info
        #endif
    }
}
