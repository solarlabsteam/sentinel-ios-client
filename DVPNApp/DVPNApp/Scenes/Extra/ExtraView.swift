//
//  ExtraView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

struct ExtraView: View {
    @ObservedObject private var viewModel: ExtraViewModel
    
    init(viewModel: ExtraViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                ExtraRowView(type: .dns(viewModel.server.title), action: viewModel.openDNSServersSelection)
                    .padding()

                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)

                ExtraRowView(type: .more, action: viewModel.openMore)
                    .padding()

                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)
            }

            Spacer()

            HStack {
                Text(L10n.Home.Extra.build)
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .bold))

                Spacer()

                Text("V\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1")")
                    .applyTextStyle(.lightGrayPoppins(ofSize: 12, weight: .light))
            }
            .padding(.horizontal)
            .padding(.bottom, 5)

            HStack {
                Button(action: viewModel.openSolarLabs) {
                    Image(uiImage: Asset.Logo.solarLabs.image)
                }
                Spacer()
                
                Button(action: viewModel.openExidio) {
                    Image(uiImage: Asset.Logo.exidio.image)
                }
            }
            .padding()
            .padding(.bottom, 10)
            .background(Asset.Colors.prussianBlue.color.asColor)
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct ExtraView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getExtraScene()
    }
}
