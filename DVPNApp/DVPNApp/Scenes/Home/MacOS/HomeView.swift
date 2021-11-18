//
//  HomeView.swift
//  DVPNApp
//
//  Created by Viktoriia Kostyleva on 11.11.2021.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.currentPage) {
                NodeSelectionView(viewModel: viewModel)
                    .tag(HomeViewModel.PageType.selector)
                    .tabItem {
                        Text(HomeViewModel.PageType.selector.title)
                    }
                
                ExtraView(
                    openServers: viewModel.openDNSServersSelection,
                    openMore: viewModel.openMore,
                    openSolarLabs: viewModel.openSolarLabs,
                    server: $viewModel.server
                )
                    .tag(HomeViewModel.PageType.extra)
                    .tabItem {
                        Text(HomeViewModel.PageType.extra.title)
                    }
            }
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: viewModel.viewWillAppear)
    }

}

extension HomeView {
    private func customize() {
//        UITableViewCell.appearance().backgroundColor = .clear
//        UITableView.appearance().backgroundColor = .clear
//
//        UIScrollView.appearance().bounces = false

//        let controlAppearance = UISegmentedControl.appearance()
//
//        controlAppearance.selectedSegmentTintColor = Asset.Colors.accentColor.color
//        controlAppearance.setTitleTextAttributes(
//            [.foregroundColor: Asset.Colors.navyBlue.color],
//            for: .selected
//        )
//        controlAppearance.setTitleTextAttributes(
//            [
//                .font: FontFamily.Poppins.semiBold.font(size: 10),
//                .foregroundColor: UIColor.white,
//                .kern: 2.5
//            ],
//            for: .normal
//        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getHomeScene()
    }
}
