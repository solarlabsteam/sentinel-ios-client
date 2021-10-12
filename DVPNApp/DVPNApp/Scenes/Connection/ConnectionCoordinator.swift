//
//  ConnectionCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.08.2021.
//

import UIKit
import SwiftUI
import SentinelWallet
import SwiftMessages

final class ConnectionCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: ConnectionModel.Context

    init(context: ConnectionModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let homeModel = ConnectionModel(context: context)
        let homeViewModel = ConnectionViewModel(model: homeModel, router: asRouter())
        let homeView = ConnectionView(viewModel: homeViewModel)
        let controller = UIHostingController(rootView: homeView)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)

        controller.makeNavigationBar(hidden: false, animated: false)
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Navigation.account.image,
            style: .plain,
            target: homeViewModel,
            action: #selector(homeViewModel.didTapAccountInfoButton)
        )
    }
}

extension ConnectionCoordinator: RouterType {
    func play(event: ConnectionViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .warning(let error):
            show(message: error.localizedDescription, theme: .warning)
        case let .openPlans(node):
            ModulesFactory.shared.makePlansModule(node: node, for: navigation)
        case .accountInfo:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case .nodeIsNotAvailable:
            show(message: "The node is not available for this moment", theme: .warning)
        }
    }
}
