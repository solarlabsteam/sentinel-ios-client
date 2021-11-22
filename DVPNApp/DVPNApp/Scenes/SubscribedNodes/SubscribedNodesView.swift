//
//  SubscribedNodesView.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.11.2021.
//

import SwiftUI

struct SubscribedNodesView: View {
    @ObservedObject private var viewModel: SubscribedNodesViewModel

    init(viewModel: SubscribedNodesViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var body: some View {
        VStack {
            if !viewModel.isLoadingSubscriptions && viewModel.subscriptions.isEmpty {
                Spacer()

                HStack {
                    Spacer()
                    
                    Text(viewModel.subscriptionsState.title)
                        .applyTextStyle(.whitePoppins(ofSize: 18, weight: .semibold))
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                Spacer()
            } else {
                List {
                    ForEach(viewModel.subscriptions, id: \.self) { vm in
                        NodeSelectionRowView(
                            viewModel: vm,
                            openDetails: {
                                viewModel.openDetails(for: vm.id)
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }

            ActivityIndicator(
                isAnimating: $viewModel.isLoadingSubscriptions,
                style: .medium
            )
        }
        .background(Asset.Colors.accentColor.color.asColor)
    }
}

extension SubscribedNodesView {
    private func customize() {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear

        UIScrollView.appearance().bounces = false

        let controlAppearance = UISegmentedControl.appearance()

        controlAppearance.selectedSegmentTintColor = Asset.Colors.accentColor.color
        controlAppearance.setTitleTextAttributes(
            [.foregroundColor: Asset.Colors.navyBlue.color],
            for: .selected
        )
        controlAppearance.setTitleTextAttributes(
            [
                .font: FontFamily.Poppins.semiBold.font(size: 10),
                .foregroundColor: UIColor.white,
                .kern: 2.5
            ],
            for: .normal
        )
    }
}

struct SubscribedNodesView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getSubscribedNodesScene()
    }
}
