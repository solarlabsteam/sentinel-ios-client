//
//  UINavigationBar+Styles.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 16.08.2021.
//

import UIKit

extension UINavigationBar {
    func applyDefaultStyle() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = Asset.Colors.accentColor.color
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            makeTransparent()
            barTintColor = Asset.Colors.accentColor.color
        }
        
        tintColor = .white
        titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.white
        ]

        backIndicatorImage = Asset.Navigation.back.image
        backIndicatorTransitionMaskImage = Asset.Navigation.back.image
    }

    func makeTransparent() {
        isTranslucent = false
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
    }
}
