//
//  AccountInfoCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 13.11.2021.
//

import SwiftUI

final class AccountInfoCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: AccountInfoModel.Context

    init(context: AccountInfoModel.Context, navigation: NavigationHelper) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model, router: asRouter())
        let view = AccountInfoView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        navigation?.switchSubview(to: controller)
    }
}

extension AccountInfoCoordinator: RouterType {
    func play(event: AccountInfoViewModel.Route) {
        switch event {
        case let .error(error):
            showErrorAlert(message: error.localizedDescription)
        case let .info(message):
#warning("Find a macOS replacement")
//            show(message: message, theme: .success)
        }
    }
}
