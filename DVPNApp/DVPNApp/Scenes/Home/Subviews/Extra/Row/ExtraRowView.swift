//
//  ExtraRowView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

struct ExtraRowView: View {
    private let type: ExtraRowViewType
    private let action: () -> Void

    init(type: ExtraRowViewType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack {
                HStack {
                    type.image.asImage

                    VStack(alignment: .leading) {
                        Text(type.title)
                            .applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                        Text(type.subtitle)
                            .applyTextStyle(.grayPoppins(ofSize: 11))
                    }

                    Spacer()

                    Image(systemName: "chevron.forward")
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExtraRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraRowView(type: .more, action: {})
    }
}
