//
//  CounterView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 05.10.2021.
//

import SwiftUI

struct CounterView: View {
    @Binding var text: String
    var togglePlus: () -> Void
    var toggleMinus: () -> Void
    
    private let navyColor = Asset.Colors.Redesign.navyBlue.color.asColor
    private let borderColor = Asset.Colors.Redesign.lightBlue.color.asColor

    var icon: some View {
        Image(uiImage: Asset.Tokens.dvpnBlue.image)
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
                .padding(.vertical, 30)
                .padding(.leading, 40)
                .padding(.trailing, 10)
            
            Spacer()
            
            HStack(spacing: 0) {
                Text(text)
                    .applyTextStyle(.whitePoppins(ofSize: 22, weight: .light))
                    .padding(.trailing, 30)
            }
            
            Spacer()

            Rectangle()
                .fill(borderColor)
                .frame(width: 1)
                .edgesIgnoringSafeArea(.horizontal)

            VStack(spacing: 15) {
                Button(action: togglePlus) {
                    Image(uiImage: Asset.Counter.plus.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(navyColor)
                }
                .padding(.horizontal, 20)

                Rectangle()
                    .fill(borderColor)
                    .frame(height: 1)
                    .edgesIgnoringSafeArea(.horizontal)

                Button(action: toggleMinus) {
                    Image(uiImage: Asset.Counter.minus.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .foregroundColor(navyColor)
                }
                .padding(.horizontal, 20)
            }
            .fixedSize()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(borderColor, lineWidth: 1)
        )
        .fixedSize()
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(text: .constant("50 DVPN"), togglePlus: {}, toggleMinus: {})
    }
}
