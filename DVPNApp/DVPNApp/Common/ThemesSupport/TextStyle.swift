//
//  TextStyle.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import Foundation
import SwiftUI

#if os(macOS)
struct TextStyle {
    let font: NSFont
    let color: NSColor
    let kern: Double
}

#elseif os(iOS)
struct TextStyle {
    let font: UIFont
    let color: UIColor
    let kern: Double
}
#endif

extension TextStyle {
    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: color,
            .kern: kern
        ]
    }
}

protocol TextStyleApplicable {
    associatedtype T
    func applyTextStyle(_ textStyle: TextStyle) -> T
}

// MARK: - Text

extension Text: TextStyleApplicable {
    func applyTextStyle(_ textStyle: TextStyle) -> Text {
        font(textStyle.font.asSwiftUIFont)
            .kerning(textStyle.kern)
            .foregroundColor(textStyle.color.asColor)
    }
}

// MARK: - TextField

extension TextField: TextStyleApplicable {
    func applyTextStyle(_ textStyle: TextStyle) -> some View {
        font(textStyle.font.asSwiftUIFont)
            .foregroundColor(textStyle.color.asColor)
            .accentColor(textStyle.color.asColor)
    }
}
