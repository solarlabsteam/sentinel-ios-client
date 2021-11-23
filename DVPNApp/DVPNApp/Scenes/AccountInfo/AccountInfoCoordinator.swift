//
//  AccountInfoCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 03.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

final class AccountInfoCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: AccountInfoModel.Context

    init(context: AccountInfoModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model, router: asRouter())
        let view = AccountInfoView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.TabBar.Item.account
    }
}

extension AccountInfoCoordinator: RouterType {
    func play(event: AccountInfoViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .info(message):
            show(message: message, theme: .success)
        case .purchases:
            ModulesFactory.shared.makePurchasesModule(for: navigation)
        }
    }
}
