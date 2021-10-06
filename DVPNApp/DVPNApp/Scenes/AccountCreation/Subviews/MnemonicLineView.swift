//
//  MnemonicLineView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import Foundation
import SwiftUI

struct MnemonicLineView: View {
    var range: [Int]

    @Binding var mnemonic: [String]
    @Binding var isEnabled: Bool

    var body: some View {
        HStack(spacing: 10) {
            ForEach(range, id: \.self) { value in
                ZStack(alignment: .leading) {
                    TextField("", text: $mnemonic[value])
                        .applyTextStyle(.whitePoppins(ofSize: 11, weight: .medium))
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .padding(.bottom, 10)
                        .padding([.horizontal, .top], 8)
                        .border(Asset.Colors.Redesign.borderGray.color.asColor, width: 1)
                        .cornerRadius(2)
                        .padding(.top, 20)
                        .disabled(!isEnabled)

                    HStack {
                        Spacer().frame(width: 10, height: 10)
                        Text(value + 1 < 10 ? "0\(value + 1)" : "\(value + 1)")
                            .applyTextStyle(.textBody)
                            .padding([.horizontal], 5)
                            .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
                    }
                    .padding(.bottom, 12)
                }
            }

        }
    }
}
