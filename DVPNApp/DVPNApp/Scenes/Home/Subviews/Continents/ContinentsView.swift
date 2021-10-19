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
            ForEach(viewModel.continents, id: \.self) { continent in
                ContinentsRowView(
                    type: continent,
                    count: .constant(0),
                    action: {
                        viewModel.openNodes(for: continent)
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
