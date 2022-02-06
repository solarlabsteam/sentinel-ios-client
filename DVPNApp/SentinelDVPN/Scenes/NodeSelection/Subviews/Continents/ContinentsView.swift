//
//  ContinentsView.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 14.10.2021.
//

import SwiftUI

struct ContinentsView: View {
    @ObservedObject private var viewModel: NodeSelectionViewModel

    @State private var openContinent: Continent?

    init(viewModel: NodeSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        print(Self._printChanges())
        return NavigationView {
            VStack(spacing: 0) {
                ForEach(
                    Continent.allCases,
                    id: \.self
                ) { key in
                    ContinentsRowView(
                        type: key,
                        count: .constant(viewModel.numberOfNodesInContinent[key] ?? 0),
                        action: { openContinent = key }
                    )
                        .padding()

                    Divider()
                        .background(Asset.Colors.lightBlue.color.asColor)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .frame(minWidth: 220)

            if let openContinent = openContinent {
                ModulesFactory.shared.makeAvailableNodesScene(for: openContinent)
            } else {
                Text("Select a Continent")
            }
        }
    }
}
