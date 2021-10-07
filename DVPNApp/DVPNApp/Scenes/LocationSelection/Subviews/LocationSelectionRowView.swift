//
//  LocationSelectionRowView.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI
import FlagKit

struct LocationSelectionRowView: View {
    private let viewModel: LocationSelectionRowViewModel
    private let toggleLocation: () -> Void
    private let openDetails: () -> Void
    
    init(
        viewModel: LocationSelectionRowViewModel,
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
                    Image(uiImage: viewModel.icon)
                        .resizable()
                        .frame(width: 50, height: 41)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.title)
                            .applyTextStyle(.whitePoppins(ofSize: 16, weight: .medium))
                        Text(viewModel.subtitle)
                            .applyTextStyle(.lightGrayPoppins(ofSize: 10))
                    }

                    Spacer()

                    Image(uiImage: viewModel.speed)
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
                            .background(Rectangle().foregroundColor(Asset.Colors.Redesign.navyBlue.color.asColor))
                    }
                    .cornerRadius(4)
                }
                .padding(.bottom)
            }
        }
    }
}

struct LocationSelectionRowView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSelectionRowView(
            viewModel:
                    .init(
                        id: "id",
                        icon: Flag(countryCode: "EE")!.image(style: .roundedRect),
                        title: "Test",
                        subtitle: "mfq9rph",
                        price: 0.7,
                        speed: Asset.Home.Wifi.scales1.image,
                        latency: 0.2,
                        peers: 0.3
                    ),
            toggleLocation: {},
            openDetails: {}
        )
    }
}
