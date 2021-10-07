//
//  AccentButton.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 07.10.2021.
//

import SwiftUI

struct AccentButton: View {
    var title: String
    var clicked: (() -> Void)
    
    var body: some View {
        Button(action: clicked) {
            HStack {
                Text(title)
                    .foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor)
                    .font(.system(size: 11, weight: .semibold))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Asset.Colors.Redesign.navyBlue.color.asColor)
        .cornerRadius(25)
    }
}
