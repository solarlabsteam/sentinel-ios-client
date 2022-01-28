//
//  GridView.swift
//  SentinelDVPN
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
    
    private let borderColor = Asset.Colors.gridBorder.color.asColor
    
    init(
        models: [GridViewModelType]
    ) {
        self.chunkedModels = models.chunked(into: 2)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(chunkedModels.indices, chunkedModels)), id: \.0) { index, modelPair in
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        HStack {
                            if let modelType0 = modelPair[safe: 0] {
                                getItemView(from: modelType0)
                            }
                            
                            Rectangle()
                                .fill(borderColor)
                                .frame(width: 1)
                            
                            if let modelType1 = modelPair[safe: 1] {
                                getItemView(from: modelType1)
                            }
                        }
                        
                        if index > 0, index < chunkedModels.count {
                            Circle()
                                .strokeBorder(borderColor, lineWidth: 1)
                                .background(Circle().foregroundColor(Asset.Colors.accentColor.color.asColor))
                                .frame(width: 16, height: 16)
                                .padding(.top, -8)
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
                .connectionInfo(.init(type: .download, value: "59.8", symbols: "KB/s")),
                .connectionInfo(.init(type: .upload, value: "19.8", symbols: "MB/s")),
                .connectionInfo(.init(type: .bandwidth, value: "300", symbols: "GB")),
                .connectionInfo(.init(type: .duration, value: "22 m 30 s", symbols: ""))
            ]
        )
    }
}

extension GridView {
    @ViewBuilder
    private func getItemView(from gridViewModel: GridViewModelType) -> some View {
        switch gridViewModel {
        case let .connectionInfo(model):
            ConnectionInfoView(viewModel: model)
        case let .nodeInfo(model):
            NodeInfoView(viewModel: model)
        }
    }
}
