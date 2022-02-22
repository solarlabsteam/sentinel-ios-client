//
//  NodeSelectionView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 18.01.2022.
//

import Cocoa
import SwiftUI
import AlertToast

struct NodeSelectionView: View {
    @ObservedObject private var viewModel: NodeSelectionViewModel

    init(viewModel: NodeSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            if case let .subscribed(type) = viewModel.selectedTab,
               case let .details(node, isSubscribed) = type {
                Button(action: viewModel.closeDetails) {
                    Text(L10n.Common.back).applyTextStyle(.navyBluePoppins(ofSize: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .padding()

                ModulesFactory.shared.makeNodeDetailsScene(node: node, isSubscribed: isSubscribed)
            } else if case let .available(type) = viewModel.selectedTab,
                      case let .continent(continent) = type {

                Button(action: viewModel.closeContinent) {
                    Text(L10n.Common.back).applyTextStyle(.navyBluePoppins(ofSize: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .padding()

                ModulesFactory.shared.makeAvailableNodesScene(for: continent)
            } else {
                embedBody
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .toast(isPresenting: $viewModel.alertContent.isShown) {
            viewModel.alertContent.toast
        }
        .sheet(isPresented: $viewModel.showPlansSheet, onDismiss: nil, content: {
            if let nodeInfo = viewModel.nodeToToggle?.info {
                ModulesFactory.shared.makePlansScene(
                    nodeInfo: nodeInfo,
                    isPresented: $viewModel.showPlansSheet
                )
            }
        })
    }
}

// MARK: - Subviews

extension NodeSelectionView {
    private var embedBody: some View {
        VStack {
            SegmentedPickerView(
                $viewModel.selectedTab,
                elements: NodeType.allCases.map { nodeType in
                    (id: nodeType, view: AnyView(SegmentedPickerElementView {
                        Text(nodeType.title).applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                    }))
                }
            )
            .padding(.horizontal, 40)
            .padding(.vertical, 20)

            HStack {
                switch viewModel.selectedTab {
                case .subscribed:
                    subscribedNodes
                case .available:
                    continentsView
                }
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }

    private var subscribedNodes: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                    emptySubscribedNodes
                } else {
                    subscribedNodesList
                }
            }
            
            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                controlSize: .small
            )
                .padding(.bottom)
        }
    }
    
    private var emptySubscribedNodes: some View {
        VStack {
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
        }
    }
    
    private var subscribedNodesList: some View {
        List {
            ForEach(viewModel.subscriptions, id: \.self) { vm in
                NodeSelectionRowView(
                    viewModel: vm,
                    toggleLocation: {
                        viewModel.toggleLocation(with: vm.id)
                    },
                    openDetails: {
                        viewModel.openDetails(for: vm.id)
                    },
                    isConnectionButtonDisabled: $viewModel.isConnectionButtonDisabled
                )
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var continentsView: some View {
        ContinentsView(viewModel: viewModel)
    }
}

struct NodeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getNodeSelectionScene()
    }
}
