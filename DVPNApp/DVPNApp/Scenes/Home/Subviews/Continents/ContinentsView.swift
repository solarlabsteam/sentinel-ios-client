//
//  ContinentsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: HomeViewModel
    
    let chunkedModels: [[Dictionary<Continent, Int>.Element]]

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        
        chunkedModels = viewModel.numberOfNodesInContinent.sorted { $0.key.index < $1.key.index }
            .chunked(into: 2)
    }
    
    var body: some View {
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
    }
}
