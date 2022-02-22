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
    @Binding var isConnectionButtonDisabled: Bool
    
    init(
        viewModel: NodeSelectionRowViewModel,
        toggleLocation: @escaping () -> Void,
        openDetails: @escaping () -> Void,
        isConnectionButtonDisabled: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.toggleLocation = toggleLocation
        self.openDetails = openDetails
        self._isConnectionButtonDisabled = isConnectionButtonDisabled
    }

    var body: some View {
        Button(action: openDetails) {
            VStack {
                HStack(alignment: .bottom) {
                    viewModel.icon.asImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(5)
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
                    .disabled(isConnectionButtonDisabled)
                    .buttonStyle(PlainButtonStyle())
                    .cornerRadius(4)
                }
                .padding(.bottom)
            }
        }
        .buttonStyle(CommonButtonStyle(backgroundColor: Asset.Colors.accentColor.color))
    }
}

// swiftlint:disable force_unwrapping

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
            openDetails: {},
            isConnectionButtonDisabled: .constant(false)
        )
    }
}

// swiftlint:enable force_unwrapping
