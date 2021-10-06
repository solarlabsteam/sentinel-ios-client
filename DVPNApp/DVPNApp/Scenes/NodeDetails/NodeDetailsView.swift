//
//  NodeDetailsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI

struct NodeDetailsView: View {
    
    @ObservedObject private var viewModel: NodeDetailsViewModel
    
    init(viewModel: NodeDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var locationSelector: some View {
        CountryTileView(
            viewModel: .init(
                id: viewModel.countryTileModel?.id ?? "",
                icon: viewModel.countryTileModel?.icon ?? UIImage(),
                title: viewModel.countryTileModel?.title ?? "",
                subtitle: viewModel.countryTileModel?.subtitle ?? "",
                speed: viewModel.countryTileModel?.speedImage ?? UIImage()
            )
        )
        .padding(.horizontal, 16)
    }
    
    var gridView: some View {
        GridView(models: viewModel.gridViewModels)
    }
    
    // TODO: Localize
    var mainButton: some View {
        Button(action: viewModel.didTapConnect) {
            HStack {
                Spacer()
                Text("CONNECT NOW")
                    .foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor)
                    .font(.system(size: 13, weight: .semibold))

                Spacer()
            }
        }
        .padding()
        .background(Asset.Colors.Redesign.navyBlue.color.asColor)
        .cornerRadius(25)
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
        .background(Asset.Colors.Redesign.backgroundColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
    }
}
