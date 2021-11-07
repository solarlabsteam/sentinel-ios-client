//
//  OnboardingCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 11.08.2021.
//

import UIKit
import SwiftUI
import SentinelWallet

final class OnboardingCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?
    private weak var window: UIWindow?

    private let context: OnboardingModel.Context

    init(context: OnboardingModel.Context, navigation: UINavigationController, window: UIWindow) {
        self.context = context
        self.navigation = navigation
        self.window = window
    }

    func start() {
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: asRouter())
        let view = OnboardingView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: true, animated: false)
    }
}

extension OnboardingCoordinator: RouterType {
    func play(event: OnboardingViewModel.Route) {
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .createAccount(mode):
            if let navigation = navigation, let window = window {
                ModulesFactory.shared.makeAccountCreationModule(mode: mode, for: navigation, window: window)
            }
        }
    }
}
