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

                Spacer()
            } else {
                List {
                    ForEach(viewModel.subscriptions, id: \.self) { vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            openDetails: {
                                viewModel.openDetails(for: vm.id)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
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
