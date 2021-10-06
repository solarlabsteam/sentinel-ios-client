//
//  MainGradient.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.09.2021.
//

import SwiftUI

struct MainGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Asset.Colors.Gradient.lightBlue.color.asColor,
                    Asset.Colors.Gradient.darkBlue.color.asColor
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
