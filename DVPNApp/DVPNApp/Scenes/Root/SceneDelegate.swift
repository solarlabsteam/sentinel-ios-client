//
//  SceneDelegate.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 10.06.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            log.error("Couldn't load windowScene")
            return
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowScene = windowScene
        ModulesFactory.shared.detectStartModule(for: window)
        self.window = window
        window.makeKeyAndVisible()
    }
}
