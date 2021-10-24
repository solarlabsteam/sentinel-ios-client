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
    private let openSolarLabs: () -> Void
    @Binding private var server: DNSServerType

    init(
        openServers: @escaping () -> Void,
        openMore: @escaping () -> Void,
        openSolarLabs: @escaping () -> Void,
        server: Binding<DNSServerType>
    ) {
        self.openMore = openMore
        self.openServers = openServers
        self.openSolarLabs = openSolarLabs
        self._server = server
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                ExtraRowView(type: .dns(server.title), action: openServers)
                    .padding()

                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)

                ExtraRowView(type: .more, action: openMore)
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
                Button(action: openSolarLabs) {
                    Image(uiImage: Asset.Logo.solarLabs.image)
                }
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
        ExtraView(openServers: {}, openMore: {}, openSolarLabs: {}, server: .constant(.default))
    }
}
