//
//  FramedButton.swift
//  DVPNApp
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
                    .applyTextStyle(.whiteMain(ofSize: 12, weight: .regular))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Asset.Colors.navyBlue.color.asColor, lineWidth: 1)
        )
    }
}
