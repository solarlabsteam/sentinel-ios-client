//
//  AccountInfoRowView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import SwiftUI

struct DNSSettingsRowView: View {
    private let model: DNSSettingsRowViewModel
    private let toggleSelection: () -> Void

    init(model: DNSSettingsRowViewModel, toggleSelection: @escaping () -> Void) {
        self.model = model
        self.toggleSelection = toggleSelection
    }

    var body: some View {
        Button(action: toggleSelection) {
            VStack {
                HStack {
                    Image(uiImage: model.type.image)
                        .frame(width: 25, height: 25)
                        .padding(3)
                        .background(Color.white)
                        .cornerRadius(5)

                    VStack(alignment: .leading) {
                        Text(model.type.title)
                            .applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                        Text(model.type.address)
                            .applyTextStyle(.grayPoppins(ofSize: 11))
                    }

                    Spacer()

                    if model.isSelected {
                        Image(systemName: "checkmark.square")
                            .foregroundColor(Asset.Colors.navyBlue.color.asColor)
                    } else {
                        Image(systemName: "square")
                            .foregroundColor(Asset.Colors.borderGray.color.asColor)
                    }
                }
            }
        }
    }
}

struct DNSSettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DNSSettingsRowView(model: .init(type: .freenom, isSelected: true), toggleSelection: {})
            DNSSettingsRowView(model: .init(type: .cloudflare, isSelected: false), toggleSelection: {})
        }
    }
}
