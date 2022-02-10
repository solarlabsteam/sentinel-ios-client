//
//  AccentButton.swift
//  SentinelDVPN
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
                    .foregroundColor(Asset.Colors.accentColor.color.asColor)
                    .applyTextStyle(.darkPoppins(ofSize: 11, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .buttonStyle(CommonButtonStyle(backgroundColor: Asset.Colors.navyBlue.color))
        .cornerRadius(25)
    }
}
