//
//  ContinentsView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(
                viewModel.numberOfNodesInContinent.sorted { $0.key.index < $1.key.index },
                id: \.key
            ) { key, value in
                ContinentsRowView(
                    type: key,
                    count: .constant(value),
                    action: {
                        viewModel.openNodes(for: key)
                    })
                    .padding()
                
                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}
