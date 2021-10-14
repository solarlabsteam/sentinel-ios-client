//
//  AccountCreationCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import UIKit
import SwiftUI
import SentinelWallet

private struct Constants {
    let privacyURL = URL(string: "https://sentinel.co/privacy")
}

private let constants = Constants()

final class AccountCreationCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?
    private weak var window: UIWindow?

    private let context: AccountCreationModel.Context
    private let mode: CreationMode

    init(
        context: AccountCreationModel.Context,
        mode: CreationMode,
        navigation: UINavigationController,
        window: UIWindow
    ) {
        self.context = context
        self.mode = mode
        self.navigation = navigation
        self.window = window
    }

    func start() {
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: asRouter())
        let view = AccountCreationView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)

        controller.makeNavigationBar(hidden: false, animated: true)
    }
}

extension AccountCreationCoordinator: RouterType {
    func play(event: AccountCreationViewModel.Route) {
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .privacy:
            if let url = constants.privacyURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case .openNodes:
            ModulesFactory.shared.makeHomeModule(for: window!)
        case let .title(title):
            rootController?.title = title
        }
    }
}
