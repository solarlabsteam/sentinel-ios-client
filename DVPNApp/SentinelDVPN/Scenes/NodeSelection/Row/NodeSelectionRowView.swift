//
//  NodeSelectionRowView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI
import FlagKit

struct NodeSelectionRowView: View {
    private let viewModel: NodeSelectionRowViewModel
    private let toggleLocation: () -> Void
    private let openDetails: () -> Void
    
    init(
        viewModel: NodeSelectionRowViewModel,
        toggleLocation: @escaping () -> Void,
        openDetails: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.toggleLocation = toggleLocation
        self.openDetails = openDetails
    }

    var body: some View {
        Button(action: openDetails) {
            VStack {
                HStack(alignment: .bottom) {
                    viewModel.icon.asImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 41)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.title)
                            .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
                        Text(viewModel.subtitle)
                            .applyTextStyle(.lightGrayPoppins(ofSize: 10))
                    }

                    Spacer()

                    viewModel.speed.asImage
                        .padding(.all, 5)
                }
                .padding(.vertical)

                HStack {
                    ForEach(viewModel.scales, id: \.self) { type in
                        ScaleView(type: type)
                            .frame(maxWidth: .infinity)
                    }

                    Button(action: toggleLocation) {
                        Image(systemName: "link")
                            .frame(width: 38, height: 38)
                            .background(Rectangle().foregroundColor(Asset.Colors.navyBlue.color.asColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .cornerRadius(4)
                }
                .padding(.bottom)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// swiftlint:disable force_unwrapping

#if os(iOS)
struct HomeRowView_Previews: PreviewProvider {
    static var previews: some View {
        NodeSelectionRowView(
            viewModel:
                    .init(
                        id: "id",
                        icon: Flag(countryCode: "EE")!.image(style: .roundedRect),
                        title: "Test",
                        subtitle: "mfq9rph",
                        price: 100,
                        speed: Asset.Connection.Wifi.scales1.image,
                        latency: 300,
                        peers: 4
                    ),
            toggleLocation: {},
            openDetails: {}
        )
    }
}
#endif

#if os(macOS)
struct HomeRowView_Previews: PreviewProvider {
    static var previews: some View {
        NodeSelectionRowView(
            viewModel:
                    .init(
                        id: "id",
                        icon: Flag(countryCode: "EE")!.originalImage,
                        title: "Test",
                        subtitle: "mfq9rph",
                        price: 100,
                        speed: Asset.Connection.Wifi.scales1.image,
                        latency: 300,
                        peers: 4
                    ),
            toggleLocation: {},
            openDetails: {}
        )
    }
}
#endif

// swiftlint:enable force_unwrapping
