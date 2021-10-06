//
//  GridView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI

enum GridViewModelType: Hashable {
    case connectionInfo(ConnectionInfoViewModel)
    case nodeInfo(NodeInfoViewModel)
}

struct GridView: View {
    private let chunkedModels: [[GridViewModelType]]
    
    private let borderColor = Asset.Colors.Redesign.gridBorder.color.asColor
    
    init(
        models: [GridViewModelType]
    ) {
        self.chunkedModels = models.chunked(into: 2)
    }
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(chunkedModels.indices, chunkedModels)), id: \.0) { index, modelPair in
                VStack(spacing: 0) {
                    if index > 0, index < chunkedModels.count {
                        Circle()
                            .strokeBorder(borderColor, lineWidth: 1)
                            .background(Circle().foregroundColor(Asset.Colors.Redesign.backgroundColor.color.asColor))
                            .frame(width: 16, height: 16)
                            .padding(.top, -8)
                    }
                    
                    HStack {
                        // TODO: @tori do not copy-pase
                        
                        let modelType0 = modelPair[safe: 0]
                        
                        if let modelType0 = modelType0 {
                            switch modelType0 {
                            case let .connectionInfo(model):
                                ConnectionInfoView(viewModel: model)
                            case let .nodeInfo(model):
                                NodeInfoView(viewModel: model)
                            }
                        }
                        
                        Rectangle()
                            .fill(borderColor)
                            .frame(width: 1)
                        
                        let modelType1 = modelPair[safe: 1]
                        
                        if let modelType1 = modelType1 {
                            switch modelType1 {
                            case let .connectionInfo(model):
                                ConnectionInfoView(viewModel: model)
                            case let .nodeInfo(model):
                                NodeInfoView(viewModel: model)
                            }
                        }
                    }
                    
                    if index < chunkedModels.count - 1 {
                        Rectangle()
                            .fill(borderColor)
                            .frame(height: 1)
                    }
                }
            }
        }.fixedSize()
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(
            models: [
                .connectionInfo(.init(type: .download, value: "test 1", symbols: "aa")),
                .connectionInfo(.init(type: .upload, value: "test 2", symbols: "bb")),
                .connectionInfo(.init(type: .bandwidth, value: "test 3", symbols: "dd")),
                .connectionInfo(.init(type: .duration, value: "test 4", symbols: "cc"))
            ]
        )
    }
}
