//
//  TextStyle.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import Foundation
import SwiftUI

struct TextStyle {
    let font: UIFont
    let color: UIColor
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

// MARK: - Text's TextStyleApplicable implementation

extension Text: TextStyleApplicable {
    func applyTextStyle(_ textStyle: TextStyle) -> Text {
        font(textStyle.font.asSwiftUIFont)
            .kerning(textStyle.kern)
            .foregroundColor(textStyle.color.asColor)
    }
}
