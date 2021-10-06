//
//  LocationSelectionRowView.swift
//  Test
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import SwiftUI
import FlagKit

struct LocationSelectionRowView: View {
    
    private var viewModel: LocationSelectionRowViewModel
    private var toggleLocation: () -> Void
    private var openDetails: () -> Void
    
    init(
        viewModel: LocationSelectionRowViewModel,
        toggleLocation: @escaping () -> Void,
        openDetails: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.toggleLocation = toggleLocation
        self.openDetails = openDetails
    }

    private struct ScaleView: View {
        let scales = [0, 0.2, 0.4, 0.6, 0.8]
        var title: String
        var scale: Double

        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                HStack {
                    HStack(spacing: 2) {
                        ForEach(scales, id: \.self) { value in
                            Rectangle()
                                .foregroundColor(value < scale ? .white.opacity(value + 0.2) : .clear)
                                .frame(width: 8, height: 6)
                        }
                    }
                    .cornerRadius(1)
                    .padding(.all, 2)
                    .border(Color.white.opacity(0.2), width: 0.5)
                    .cornerRadius(2)

                    Spacer()
                }
            }
        }
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text(viewModel.subtitle)
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Image(uiImage: viewModel.speed)
                        .padding(.all, 5)
                }
                .padding(.vertical)

                HStack {
                    ScaleView(title: L10n.LocationSelection.Node.Details.price, scale: viewModel.price)
                        .frame(maxWidth: .infinity)
                    ScaleView(title: L10n.LocationSelection.Node.Details.peers, scale: viewModel.peers)
                        .frame(maxWidth: .infinity)
                    ScaleView(title: L10n.LocationSelection.Node.Details.latency, scale: viewModel.latency)
                        .frame(maxWidth: .infinity)


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
