//
//  ExtraView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

struct ExtraView: View {
    private let openMore: () -> Void
    private let openServers: () -> Void
    @Binding private var servers: String

    init(
        openServers: @escaping () -> Void,
        openMore: @escaping () -> Void,
        servers: Binding<String>
    ) {
        self.openMore = openMore
        self.openServers = openServers
        self._servers = servers
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                ExtraRowView(type: .dns(servers), action: openServers)
                        .listRowBackground(Color.clear)
                        .padding()

                Divider()
                    .foregroundColor(Asset.Colors.navyBlue.color.asColor)
                    .padding(.horizontal)

                ExtraRowView(type: .more, action: openMore)
                        .listRowBackground(Color.clear)
                        .padding()

                Divider()
                    .foregroundColor(Asset.Colors.navyBlue.color.asColor)
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
                Image(uiImage: Asset.Logo.cosmos.image)
                Spacer()
                Image(uiImage: Asset.Logo.exidio.image)
            }
            .padding()
            .padding(.bottom, 10)
            .background(Asset.Colors.prussianBlue.color.asColor)
        }
    }
}

struct ExtraView_Previews: PreviewProvider {
    static var previews: some View {
        ExtraView(openServers: {}, openMore: {}, servers: .constant("Freenom"))
    }
}
