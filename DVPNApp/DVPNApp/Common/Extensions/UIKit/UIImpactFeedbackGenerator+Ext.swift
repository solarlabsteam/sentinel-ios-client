//
//  UIImpactFeedbackGenerator+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import UIKit

extension UIImpactFeedbackGenerator {
    static func lightFeedback() {
        UIImpactFeedbackGenerator().impactOccurred(intensity: 0.4)
    }
}
