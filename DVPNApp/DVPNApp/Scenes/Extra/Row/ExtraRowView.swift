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
                    type.image
                        .foregroundColor(Asset.Colors.navyBlue.color.asColor)

                    VStack(alignment: .leading) {
                        Text(type.title)
                            .applyTextStyle(.whiteMain(ofSize: 14, weight: .medium))
                        Text(type.subtitle)
                            .applyTextStyle(.grayMain(ofSize: 11))
                    }

                    Spacer()

                    Image(systemName: "chevron.forward")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct ExtraRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraRowView(type: .more, action: {})
    }
}
