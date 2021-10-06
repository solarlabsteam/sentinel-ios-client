//
//  ConnectionInfoView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import SwiftUI

struct ConnectionInfoView: View {
    private var viewModel: ConnectionInfoViewModel
    
    init(
        viewModel: ConnectionInfoViewModel
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
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .bottom, spacing: 2) {
                Text(viewModel.value )
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(viewModel.symbols ?? "")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Asset.Colors.Redesign.veryLightGray.color.asColor)
            }
            
            Text(viewModel.type.title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Asset.Colors.Redesign.borderGray.color.asColor)
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            icon
            textContentView
        }
        .frame(width: 164, height: 80)
    }
}

struct ConnectionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionInfoView(
            viewModel:
                .init(
                    type: .upload,
                    value: "19.8",
                    symbols: "KB/s"
                )
        )
    }
}
