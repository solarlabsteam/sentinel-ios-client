//
//  NodeInfoView.swift
//  SentinelDVPN
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
    
    // MARK: - Common view
    
    var icon: some View {
        viewModel.type.icon.asImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 26, height: 26)
            .foregroundColor(.white)
    }
    
    var textContentView: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(viewModel.type.title)
                .font(.system(size: 10, weight: .light))
                .applyTextStyle(.grayPoppins(ofSize: 10, weight: .medium))
            
            Text(viewModel.value)
                .applyTextStyle(.whitePoppins(ofSize: 12, weight: .medium))
        }
        .frame(width: 174, height: 45)
    }
    
    // MARK: - Feature view
    
    struct FeatureIcon: View {
        var asset: ImageAsset
        
        var body: some View {
            asset.image.asImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 26, height: 26)
                .foregroundColor(.white)
        }
    }
    
    var featuresView: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(alignment: .center) {
                FeatureIcon(asset: Asset.Node.Features.wireGuard)
                FeatureIcon(asset: Asset.Node.Features.handshake)
            }.padding(.bottom, 3)
            
            Text(viewModel.type.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: 174, height: 60)
    }
    
    // MARK: - Body
    
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
            viewModel: .init(
                type: .city,
                value: "Test city"
            )
        )
    }
}
