//
//  Toolbar.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 18.11.2021.
//

import Foundation
import SwiftUI

struct Toolbar: View {
    var toggleButton: () -> Void

    var body: some View {
        HStack {
            Button(action: toggleButton) {
                Asset.Navigation.account.image.asImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 20, height: 20)
            .buttonStyle(PlainButtonStyle())
            .padding(.all, 10)

            Spacer()
        }
    }
}
