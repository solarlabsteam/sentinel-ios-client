//
//  LaunchView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 15.02.2022.
//

import SwiftUI

struct LaunchView: View {
    @ObservedObject private var viewModel: LaunchViewModel
    
    init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .center) {
                icon
                textContentView
                
                ActivityIndicator(isAnimating: .constant(true), controlSize: .regular)
                
            }
            .frame(width: 300, height: 300)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Asset.Colors.accentColor.color.asColor)
    }
}
    
extension LaunchView {
    var icon: some View {
        Asset.Launch.sentinelBig.image.asImage
    }
    
    var textContentView: some View {
        VStack(alignment: .center) {
            Text("Sentinel")
                .applyTextStyle(.whitePoppins(ofSize: 25, weight: .medium))
            
            Text(L10n.Launch.description)
                .applyTextStyle(.lightGrayPoppins(ofSize: 15, weight: .regular))
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getLaunchView()
    }
}
