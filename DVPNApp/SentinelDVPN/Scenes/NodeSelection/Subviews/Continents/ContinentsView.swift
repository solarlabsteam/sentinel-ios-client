//
//  ContinentsView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: NodeSelectionViewModel

    init(viewModel: NodeSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(
                Continent.allCases,
                id: \.self
            ) { key in
                ContinentsRowView(
                    type: key,
                    count: .constant(viewModel.numberOfNodesInContinent[key] ?? 0),
                    action: { viewModel.openContinent(key: key) }
                )
                    .padding()

                Divider()
                    .background(Asset.Colors.lightBlue.color.asColor)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
