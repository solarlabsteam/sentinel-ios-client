//
//  AppDelegate.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 10.06.2021.
//

import UIKit
import RevenueCat


private struct Constants {
    let purchasesAPIKey = "VuFNBdQJOUDGYPjJmFTeamGmRBqRAMcp"
}

private let constants = Constants()


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Config.setup()

        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif

        Purchases.configure(withAPIKey: constants.purchasesAPIKey)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}
