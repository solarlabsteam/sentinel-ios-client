//
//  AvailableNodesView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 18.10.2021.
//

import SwiftUI

struct AvailableNodesView: View {
    @ObservedObject private var viewModel: AvailableNodesViewModel

    init(viewModel: AvailableNodesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(L10n.AvailableNodes.title(viewModel.continent.title))
                .applyTextStyle(.grayPoppins(ofSize: 12, weight: .medium))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
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
//                            TODO: @Tori
//                                viewModel.toggleLocation(with: vm.id)
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
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingNodes,
                style: .medium
            ).padding()
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}
