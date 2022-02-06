//
//  AvailableNodesView.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import SwiftUI

struct AvailableNodesView: View {
    @ObservedObject private var viewModel: AvailableNodesViewModel

    init(viewModel: AvailableNodesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if case let .details(node) = viewModel.selectedType {
                #warning("TODO add button the way it won't duplicate previous one")
//                Button(action: viewModel.closeDetails) {
//                    Text(L10n.Common.back)
//                        .applyTextStyle(.navyBluePoppins(ofSize: 16))
//                }
//                .buttonStyle(PlainButtonStyle())
//                .padding()

                ModulesFactory.shared.makeNodeDetailsScene(node: node, isSubscribed: true)
            } else {
                ZStack(alignment: .bottom) {
                    VStack {
                        continentNameTitle

                        if viewModel.locations.isEmpty {
                            notFoundView
                        } else {
                            nodesListView
                        }
                    }

                    ActivityIndicator(
                        isAnimating: $viewModel.isLoadingNodes,
                        controlSize: .regular
                    ).padding()
                }
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .toast(isPresenting: $viewModel.alertContent.isShown) {
            viewModel.alertContent.toast
        }
    }
}

// MARK: - Subviews

extension AvailableNodesView {
    var continentNameTitle: some View {
        HStack {
            Text(L10n.AvailableNodes.title(viewModel.continent.title))
                .applyTextStyle(.grayPoppins(ofSize: 12, weight: .medium))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var notFoundView: some View {
        VStack {
            Spacer()
            
            Text(L10n.Home.Node.All.notFound)
                .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                .padding()
                .multilineTextAlignment(.center)
            
            Asset.LocationSelector.empty.image.asImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 250)

            Spacer()
        }
    }
    
    var nodesListView: some View {
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
}
