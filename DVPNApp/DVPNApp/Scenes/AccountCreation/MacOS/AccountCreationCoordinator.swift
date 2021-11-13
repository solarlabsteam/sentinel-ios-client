//
//  AccountCreationCoordinator.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobeva on 10.11.2021.
//

import Foundation
import Cocoa
import SwiftUI

final class AccountCreationCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: AccountCreationModel.Context
    private let mode: CreationMode

    init(context: AccountCreationModel.Context, mode: CreationMode, navigation: NavigationHelper) {
        self.context = context
        self.navigation = navigation
        self.mode = mode
    }

    func start() {
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: asRouter())
        let view = AccountCreationView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        navigation?.switchSubView(to: controller)
    }
}

extension AccountCreationCoordinator: RouterType {
    func play(event: AccountCreationViewModel.Route) {
        switch event {
        case .error(let error):
#warning("handle error properly on macOS")
            log.error(error)
        case .privacy:
            if let url = UserConstants.privacyURL {
                NSWorkspace.shared.open(url)
            }
        case .openNodes:
            break
#warning("implement on macOS")
//            if let window = window {
//                ModulesFactory.shared.makeHomeModule(for: window)
//            }
        case let .title(title):
#warning("handle titles properly on macOS")
            break
        }
    }
}
