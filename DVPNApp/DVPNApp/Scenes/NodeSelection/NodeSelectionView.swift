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
    
    var continentsView: some View {
        ContinentsView(viewModel: viewModel)
    }

    var body: some View {
        VStack {
            HStack {
                continentsView
            }

            ZStack {
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
