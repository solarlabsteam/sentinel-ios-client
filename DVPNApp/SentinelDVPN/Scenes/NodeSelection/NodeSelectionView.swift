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
        embedBody
            .background(Asset.Colors.accentColor.color.asColor)
            .toast(isPresenting: $viewModel.alertContent.isShown) {
                viewModel.alertContent.toast
            }
    }
}

// MARK: - Subviews

extension NodeSelectionView {
    private var embedBody: some View {
        VStack {
            ZStack {
                Picker("", selection: $viewModel.selectedTab) {
                    ForEach(NodeType.allCases, id: \.self) {
                        Text($0.title)
                            .applyTextStyle(.whitePoppins(ofSize: 14, weight: .medium))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .foregroundColor(Asset.Colors.navyBlue.color.asColor)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            .padding(.top, 10)

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
        .onAppear(perform: viewModel.viewWillAppear)
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
                    }
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
