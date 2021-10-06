//
//  SettingsCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 03.10.2021.
//

import Foundation

import UIKit
import SwiftUI
import SwiftMessages

final class SettingsCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: SettingsModel.Context

    init(context: SettingsModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = SettingsModel(context: context)
        let viewModel = SettingsViewModel(model: model, router: asRouter())
        let view = SettingsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)

        controller.makeNavigationBar(hidden: false, animated: false)
    }
}

extension SettingsCoordinator: RouterType {
    func play(event: SettingsViewModel.Route) {
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        }
    }
}
