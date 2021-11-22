//
//  ContinentsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: ContinentsViewModel
    
    let chunkedModels: [[Dictionary<Continent, Int>.Element]]

    init(viewModel: ContinentsViewModel) {
        self.viewModel = viewModel
        
        UIScrollView.appearance().alwaysBounceVertical = false
        
        chunkedModels = viewModel.numberOfNodesInContinent.sorted { $0.key.index < $1.key.index }
            .chunked(into: 2)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(zip(chunkedModels.indices, chunkedModels)), id: \.0) { index, models in
                        HStack(spacing: 6) {
                            ForEach(models, id: \.0) { model in
                                ContinentsRowView(
                                    type: model.key,
                                    count: .constant(model.value),
                                    action: {
                                        viewModel.openNodes(for: model.key)
                                    })
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
            }
            
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
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

struct ContinentsView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getContinentsScene()
    }
}
