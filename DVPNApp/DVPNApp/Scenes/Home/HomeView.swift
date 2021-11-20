import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        customize()
    }

    var body: some View {
        VStack(spacing: 0) {
            PageIndicator(pages: HomeViewModel.PageType.allCases, currentPage: $viewModel.currentPage)

            TabView(selection: $viewModel.currentPage) {
                ExtraView(
                    openServers: viewModel.openDNSServersSelection,
                    openMore: viewModel.openMore,
                    openSolarLabs: viewModel.openSolarLabs,
                    server: $viewModel.server
                )
                    .tag(HomeViewModel.PageType.extra)
                    .rotationEffect(.degrees(-180))

                NodeSelectionView(viewModel: viewModel)
                    .tag(HomeViewModel.PageType.selector)
                    .rotationEffect(.degrees(-180))
            }
            .rotationEffect(.degrees(-180))
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Asset.Colors.accentColor.color.asColor)
        .onAppear(perform: viewModel.viewWillAppear)
    }
}

extension HomeView {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ModulesFactory.shared.getHomeScene()
    }
}
