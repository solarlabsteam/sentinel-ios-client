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
        VStack {
            HStack {
                Text(L10n.AvailableNodes.title(viewModel.continent.title))
                    .applyTextStyle(.grayPoppins(ofSize: 12, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            if viewModel.locations.isEmpty {
                Spacer()
                
                Text(L10n.Home.Node.All.notFound)
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
                    ForEach(Array(zip(viewModel.locations.indices, viewModel.locations)), id: \.0) { index, vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            toggleLocation: {
                                viewModel.toggleLocation(with: vm.id)
                            },
                            openDetails: {
                                viewModel.openDetails(for: vm.id)
                            }
                        )
                            .onAppear {
                                if !viewModel.isAllLoaded && index <= viewModel.loadedNodesCount - 1 {
                                    viewModel.setLoadingNodes()
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
