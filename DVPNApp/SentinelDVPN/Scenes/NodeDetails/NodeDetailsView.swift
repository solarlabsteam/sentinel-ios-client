//
//  NodeDetailsView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI
import AlertToast

struct NodeDetailsView: View {
    @ObservedObject private var viewModel: NodeDetailsViewModel
    
    init(viewModel: NodeDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var locationSelector: some View {
        CountryTileView(
            viewModel: .init(
                id: viewModel.countryTileModel?.id ?? "",
                icon: viewModel.countryTileModel?.icon ?? ImageAsset.Image(),
                title: viewModel.countryTileModel?.title ?? "",
                subtitle: viewModel.countryTileModel?.subtitle ?? ""
            )
        )
        .padding(.horizontal, 16)
    }
    
    var gridView: some View {
        GridView(models: viewModel.gridViewModels)
    }
    
    var mainButton: some View {
        Button(action: viewModel.didTapConnect) {
            HStack {
                Spacer()
                Text(L10n.NodeDetails.connect)
                    .foregroundColor(Asset.Colors.accentColor.color.asColor)
                    .applyTextStyle(.mainButton)

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.navyBlue.color.asColor)
        .cornerRadius(25)
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $viewModel.showPlansSheet, onDismiss: nil, content: {
            if let nodeInfo = viewModel.node?.info {
                ModulesFactory.shared.makePlansScene(nodeInfo: nodeInfo, isPresented: $viewModel.showPlansSheet)
            }
        })
    }
    
    var body: some View {
        VStack {
            locationSelector
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            ScrollView {
                gridView
            }
            
            Spacer()
            
            mainButton
                .padding(30)
            
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .toast(isPresenting: $viewModel.alertContent.isShown) {
            viewModel.alertContent.toast
        }
    }
}
