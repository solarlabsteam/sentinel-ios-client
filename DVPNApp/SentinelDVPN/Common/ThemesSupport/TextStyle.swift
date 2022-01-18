//
//  TextStyle.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import Foundation
import SwiftUI

struct TextStyle {
    let font: NSFont
    let color: NSColor
    let kern: Double
}

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
