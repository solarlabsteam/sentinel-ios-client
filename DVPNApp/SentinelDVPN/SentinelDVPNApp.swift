//
//  SentinelDVPNApp.swift
//  SentinelDVPN
//
//  Created by Viktoriia Kostyleva on 18.01.2022.
//

import SwiftUI

@main
struct SentinelDVPNApp: App {
    var body: some Scene {
        WindowGroup {
            ModulesFactory.shared.detectStartModule()
                .frame(minWidth: 1000, minHeight: 500)
        }
    }
}
