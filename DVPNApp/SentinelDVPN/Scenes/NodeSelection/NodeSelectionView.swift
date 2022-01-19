//
//  NodeSelectionView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 18.01.2022.
//

import SwiftUI

struct NodeSelectionView: View {
    @ObservedObject private var viewModel: NodeSelectionViewModel

    init(viewModel: NodeSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ZStack {
                Picker("", selection: $viewModel.selectedTab) {
                    ForEach(NodeType.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
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
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: viewModel.viewWillAppear)
    }
}

// MARK: - Subviews

extension NodeSelectionView {
    var subscribedNodes: some View {
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
                controlSize: .large
            )
        }
    }
    
    var emptySubscribedNodes: some View {
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
    
    var subscribedNodesList: some View {
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
    
    var continentsView: some View {
        ContinentsView(viewModel: viewModel)
    }
}

struct NodeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getNodeSelectionScene()
    }
}
