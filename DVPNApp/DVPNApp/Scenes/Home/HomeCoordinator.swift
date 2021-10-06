//
//  HomeCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.08.2021.
//

import UIKit
import SwiftUI
import SentinelWallet
import SwiftMessages

final class HomeCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: HomeModel.Context

    init(context: HomeModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let homeModel = HomeModel(context: context)
        let homeViewModel = HomeViewModel(model: homeModel, router: asRouter())
        let homeView = HomeView(viewModel: homeViewModel)
        let controller = UIHostingController(rootView: homeView)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)

        controller.makeNavigationBar(hidden: false, animated: false)
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Navigation.account.image,
            style: .plain,
            target: homeViewModel,
            action: #selector(homeViewModel.didTapSettingsButton)
        )
    }
}

extension HomeCoordinator: RouterType {
    func play(event: HomeViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .warning(let error):
            show(message: error.localizedDescription, theme: .warning)
        case .subscribe(let node):
            ModulesFactory.shared.makePlansModule(node: node, for: navigation)
        case let .openPlans(node):
            ModulesFactory.shared.makePlansModule(node: node, for: navigation)
        case .settings:
            ModulesFactory.shared.makeSettingsModule(for: navigation)
        }
    }
}
