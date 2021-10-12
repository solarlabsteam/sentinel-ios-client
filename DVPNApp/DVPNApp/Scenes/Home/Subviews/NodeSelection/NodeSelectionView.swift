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

                Text(L10n.Home.Node.Subscribed.notFound)
                    .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.center)

                Image(uiImage: Asset.LocationSelector.empty.image)
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
                                viewModel.openDetails(for:  vm.id)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.green)
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
        }
    }

    var availableNodes: some View {
        VStack {
            if viewModel.isAllLoaded && viewModel.locations.isEmpty {
                Spacer()

                Text(L10n.Home.Node.All.notFound)
                    .applyTextStyle(.whitePoppins(ofSize: 17, weight: .bold))

                Spacer()
            } else {
                List {
                    ForEach(Array(zip(viewModel.locations.indices, viewModel.locations)), id: \.0) { index, vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            toggleLocation: {
                                viewModel.toggleLocation(with: vm.id)
                            },
                            openDetails: {
                                viewModel.openDetails(for:  vm.id)
                            }
                        )
                            .onAppear {
                                if index == viewModel.locations.count - 1, !viewModel.isLoadingNodes, !viewModel.isAllLoaded {
                                    viewModel.loadNodes()
                                }
                            }
                            .listRowBackground(Color.clear)

                    }
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.green)
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingNodes,
                style: .medium
            )
        }
    }

    var body: some View {
        VStack {
            HStack {
                switch(viewModel.selectedTab) {
                case .subscribed:
                    subscribedNodes
                case .available:
                    availableNodes
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
                }
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
