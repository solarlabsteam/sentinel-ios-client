//
//  NodeInfoView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI

struct NodeInfoView: View {
    private var viewModel: NodeInfoViewModel
    
    init(
        viewModel: NodeInfoViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var icon: some View {
        Image(uiImage: viewModel.type.icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 26, height: 26)
            .foregroundColor(.white)
    }
    
    var textContentView: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(viewModel.type.title)
                .font(.system(size: 10, weight: .light))
                .foregroundColor(Asset.Colors.Redesign.borderGray.color.asColor)
            
            Text(viewModel.value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 174, height: 60)
    }
    
    var featuresView: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(alignment: .center) {
                Image(uiImage: Asset.Node.Features.wireGuard.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .foregroundColor(.white)
                
                Image(uiImage: Asset.Node.Features.handshake.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .foregroundColor(.white)
            }.padding(.bottom, 3)
            
            Text(viewModel.type.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 174, height: 60)
    }
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .center) {
            if viewModel.type != .features {
                icon
                textContentView
            } else {
                featuresView
            }
        }.padding(.top, 10)
    }
}

struct NodeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NodeInfoView(
            viewModel:
                .init(
                    type: .city,
                    value: "Test one"
                )
        )
    }
}
