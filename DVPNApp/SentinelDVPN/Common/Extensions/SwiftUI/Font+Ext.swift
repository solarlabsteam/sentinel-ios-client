//
//  Font+Ext.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import Foundation
import SwiftUI

extension FontConvertible.Font {
    var asSwiftUIFont: SwiftUI.Font {
        SwiftUI.Font(self)
    }
}

// MARK: - Poppins

extension FontFamily.Poppins {
    enum weight {
        case regular
        case medium
        case italic
        case light
        case bold
        case semibold

        var fontConvertible: FontConvertible {
            let baseFont = FontFamily.Poppins.self
            switch self {
            case .regular:
                return baseFont.regular
            case .medium:
                return baseFont.medium
            case .italic:
                return baseFont.italic
            case .light:
                return baseFont.light
            case .bold:
                return baseFont.bold
            case .semibold:
                return baseFont.semiBold
            }
        }
    }
}
