//
//  ExtraView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

struct ExtraView: View {
    private let openMore: () -> Void

    init(openMore: @escaping () -> Void) {
        self.openMore = openMore
    }

    var body: some View {
        VStack(spacing: 9) {
            Spacer()
            Image(uiImage: Asset.LocationSelector.globe.image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text(L10n.Home.Extra.text)
                .applyTextStyle(.whitePoppins(ofSize: 17, weight: .bold))
                .padding([.horizontal, .top])
                .multilineTextAlignment(.center)

            Text(L10n.Home.Extra.subtitle)
                .applyTextStyle(.lightGrayPoppins(ofSize: 14))
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: openMore) {
                HStack {
                    Spacer()
                    Text(L10n.Home.Extra.Button.more.uppercased())
                        .applyTextStyle(.mainButton)

                    Spacer()
                }
            }
            .padding()
            .background(Asset.Colors.Redesign.navyBlue.color.asColor)
            .cornerRadius(25)
            .padding(.horizontal, 40)

            Spacer()

            HStack {
                HStack(spacing: 0) {
                    Text(L10n.Home.Extra.build)
                        .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))
                        .padding(.horizontal)

                    Image(uiImage: Asset.Icons.exidio.image)
                        .resizable()
                        .frame(width: 25, height: 25)

                    Text("EXIDIO")
                        .applyTextStyle(.whitePoppins(ofSize: 14, weight: .bold))
                        .padding(.horizontal, 5)
                }
                .padding()

                Spacer()


                Text("V\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1")")
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))
                    .padding(.horizontal)
                    .padding()
            }
            .padding(.bottom)
            .background(Asset.Colors.Redesign.prussianBlue.color.asColor)
        }
    }
}

struct ExtraView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraView(openMore: {})
    }
}
