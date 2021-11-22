//
//  Font+Ext.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import Foundation
import SwiftUI

extension UIFont {
    var asSwiftUIFont: SwiftUI.Font {
        Font(self as CTFont)
    }
}

// MARK: - FontWeight

enum FontWeight {
    case regular
    case medium
    case italic
    case light
    case bold
    case semibold
}
