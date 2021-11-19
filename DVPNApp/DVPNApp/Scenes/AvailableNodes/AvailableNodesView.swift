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
            if viewModel.locations.isEmpty {
                Text(L10n.Home.Node.All.notFound)
                    .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(zip(viewModel.locations.indices, viewModel.locations)), id: \.0) { index, vm in
                        NodeSelectionRowView(
                            viewModel: vm,
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
