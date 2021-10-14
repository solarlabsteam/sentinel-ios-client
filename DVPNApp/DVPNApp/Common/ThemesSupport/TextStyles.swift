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
        font: FontFamily.Poppins.semiBold.font(size: 24),
        color: .white,
        kern: 0
    )
    static let textBody = TextStyle(
        font: FontFamily.Poppins.regular.font(size: 10),
        color: .white,
        kern: 0
    )
    static let descriptionText = TextStyle(
        font: FontFamily.Poppins.light.font(size: 16),
        color: Asset.Colors.lightGray.color,
        kern: 0
    )
    static let mainButton = TextStyle(
        font: FontFamily.Poppins.semiBold.font(size: 13),
        color: Asset.Colors.accentColor.color,
        kern: 3.25
    )
    static let secondaryButton = TextStyle(
        font: FontFamily.Poppins.regular.font(size: 14),
        color: .white,
        kern: 0
    )
}

// MARK: - Convinient functions for creation text styles

extension TextStyle {
    static func whitePoppins(
        ofSize size: CGFloat,
        weight: FontFamily.Poppins.weight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        TextStyle(
            font: weight.fontConvertible.font(size: size),
            color: .white,
            kern: kern
        )
    }

    static func lightGrayPoppins(
        ofSize size: CGFloat,
        weight: FontFamily.Poppins.weight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        TextStyle(
            font: weight.fontConvertible.font(size: size),
            color: Asset.Colors.lightGray.color,
            kern: kern
        )
    }
    
    static func grayPoppins(
        ofSize size: CGFloat,
        weight: FontFamily.Poppins.weight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        TextStyle(
            font: weight.fontConvertible.font(size: size),
            color: Asset.Colors.textGray.color,
            kern: kern
        )
    }

    static func darkPoppins(
        ofSize size: CGFloat,
        weight: FontFamily.Poppins.weight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        TextStyle(
            font: weight.fontConvertible.font(size: size),
            color: Asset.Colors.accentColor.color,
            kern: kern
        )
    }

    static func navyBluePoppins(
        ofSize size: CGFloat,
        weight: FontFamily.Poppins.weight = .regular,
        kern: Double = 0
    ) -> TextStyle {
        TextStyle(
            font: weight.fontConvertible.font(size: size),
            color: Asset.Colors.navyBlue.color,
            kern: kern
        )
    }
}
