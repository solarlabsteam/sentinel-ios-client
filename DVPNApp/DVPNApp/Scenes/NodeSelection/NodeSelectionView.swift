//
//  NodeSelectionView.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.10.2021.
//

import SwiftUI

struct NodeSelectionView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var subscribedNodes: some View {
        VStack {
            if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                Spacer()

                Text(viewModel.subscriptionsState.title)
                    .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.center)

                Asset.LocationSelector.empty.image.asImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 250)

                Spacer()
            } else {
                List {
                    ForEach(viewModel.subscriptions, id: \.self) { vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            toggleLocation: {
                                viewModel.toggleLocation(with: vm.id)
                            },
                            openDetails: {
                                viewModel.openDetails(for: vm.id)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }

            #if os(iOS)
            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
            #elseif os(macOS)
            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                controlSize: .large
            )
            #endif
        }
    }
    
    var continentsView: some View {
        ContinentsView(viewModel: viewModel)
    }

    var body: some View {
        VStack {
            HStack {
                switch viewModel.selectedTab {
                case .subscribed:
                    subscribedNodes
                case .available:
                    continentsView
                }
            }

            ZStack {
                Picker("", selection: $viewModel.selectedTab) {
                    ForEach(NodeType.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Button(action: viewModel.toggleRandomLocation) {
                    Image(systemName: "power")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 60, height: 60)
                .background(viewModel.connectionStatus.powerColor)
                .cornerRadius(30)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .padding(.top, 10)
        }
    }
}

// TODO: @Lika add preview
