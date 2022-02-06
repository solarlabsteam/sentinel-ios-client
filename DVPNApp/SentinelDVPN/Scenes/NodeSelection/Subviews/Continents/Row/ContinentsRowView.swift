//
//  ContinentsRowView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsRowView: View {
    private let type: Continent
    @Binding var count: Int
    private let action: () -> Void

    init(type: Continent, count: Binding<Int>, action: @escaping () -> Void) {
        self.type = type
        self._count = count
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack {
                HStack {
                    type.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Asset.Colors.navyBlue.color.asColor)
                        .frame(width: 50, height: 50)

                    VStack(alignment: .leading) {
                        Text(type.title)
                            .applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                        Text(L10n.Continents.availableNodes(count))
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

struct ContinentsRowView_Previews: PreviewProvider {
    static var previews: some View {
        ContinentsRowView(type: .africa, count: .constant(60), action: {})
    }
}
