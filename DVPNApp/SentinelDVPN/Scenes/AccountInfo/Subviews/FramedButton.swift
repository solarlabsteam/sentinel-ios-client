//
//  FramedButton.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 07.10.2021.
//

import SwiftUI

struct FramedButton: View {
    var title: String
    var clicked: (() -> Void)
    
    var body: some View {
        Button(action: clicked) {
            HStack {
                Text(title)
                    .applyTextStyle(.whitePoppins(ofSize: 12, weight: .regular))
                    .padding(.horizontal)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(
            CommonButtonStyle(
                backgroundColor: Asset.Colors.accentColor.color,
                highlightedColor: NSColor.white.withAlphaComponent(0.05)
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Asset.Colors.navyBlue.color.asColor, lineWidth: 1)
        )
    }
}
