//
//  CommonButtonStyle.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 10.02.2022.
//

import SwiftUI

struct CommonButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let highlightedColor: Color
    
    init(
        backgroundColor: ColorAsset.Color,
        highlightedColor: ColorAsset.Color? = nil
    ) {
        self.backgroundColor = backgroundColor.asColor
        
        if let highlightedColor = highlightedColor {
            self.highlightedColor = highlightedColor.asColor
        } else {
            self.highlightedColor = backgroundColor.withAlphaComponent(0.7).asColor
        }
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? backgroundColor : highlightedColor)
            .background(configuration.isPressed ? highlightedColor : backgroundColor)
            .cornerRadius(25)
    }
}
