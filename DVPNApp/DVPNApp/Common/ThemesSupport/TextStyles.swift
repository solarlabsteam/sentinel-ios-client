//
//  TextStyles.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 06.10.2021.
//

import UIKit

// MARK: - App-wide text styles

extension TextStyle {
    static let title = TextStyle(
        font: .systemFont(ofSize: 24, weight: .semibold),
        color: .white,
        kern: 0
    )
    static let textBody = TextStyle(
        font: .systemFont(ofSize: 16, weight: .regular),
        color: .white,
        kern: 0
    )
    static let descriptionText = TextStyle(
        font: .systemFont(ofSize: 16, weight: .light),
        color: Asset.Colors.lightGray.color,
        kern: 0
    )
    static let mainButton = TextStyle(
        font: .systemFont(ofSize: 13, weight: .semibold),
        color: Asset.Colors.accentColor.color,
        kern: 3.25
    )
    static let secondaryButton = TextStyle(
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white,
        kern: 0
    )
}

extension TextStyle {
    static func style(
        ofSize size: CGFloat = 15,
        weight: FontWeight = .regular,
        kern: Double = 0,
        color: UIColor
    ) -> TextStyle {
        switch weight {
        case .regular:
            return TextStyle(font: .systemFont(ofSize: size), color: color, kern: kern)
        case .medium:
            return TextStyle(font: .systemFont(ofSize: size, weight: .medium), color: color, kern: kern)
        case .italic:
            return TextStyle(font: .italicSystemFont(ofSize: size), color: color, kern: kern)
        case .light:
            return TextStyle(font:  .systemFont(ofSize: size, weight: .light), color: color, kern: kern)
        case .bold:
            return TextStyle(font: .boldSystemFont(ofSize: size), color: color, kern: kern)
        case .semibold:
            return TextStyle(font: .systemFont(ofSize: size, weight: .semibold), color: color, kern: kern)
        }
    }
}

// MARK: - Convinient functions for creation text styles

extension TextStyle {
    static func whiteMain(
        ofSize size: CGFloat,
        weight: FontWeight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        .style(ofSize: size, weight: weight, kern: kern, color: .white)
    }

    static func lightGrayMain(
        ofSize size: CGFloat,
        weight: FontWeight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        .style(ofSize: size, weight: weight, kern: kern, color: Asset.Colors.lightGray.color)
    }
    
    static func grayMain(
        ofSize size: CGFloat,
        weight: FontWeight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        .style(ofSize: size, weight: weight, kern: kern, color: Asset.Colors.textGray.color)
    }

    static func darkMain(
        ofSize size: CGFloat,
        weight: FontWeight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        .style(ofSize: size, weight: weight, kern: kern, color: Asset.Colors.accentColor.color)
    }
    
    static func navyBlueMain(
        ofSize size: CGFloat,
        weight: FontWeight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        .style(ofSize: size, weight: weight, kern: kern, color: Asset.Colors.navyBlue.color)
    }
}
