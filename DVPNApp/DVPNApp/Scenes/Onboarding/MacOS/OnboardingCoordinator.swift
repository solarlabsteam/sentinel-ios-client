//
//  OnboardingCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Foundation
import Cocoa
import SwiftUI

final class OnboardingCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: OnboardingModel.Context

    init(context: OnboardingModel.Context, navigation: NavigationHelper) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: asRouter())
        let view = OnboardingView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        navigation?.switchSubview(to: controller)
    }
}

extension OnboardingCoordinator: RouterType {
    func play(event: OnboardingViewModel.Route) {
        switch event {
        case let .createAccount(mode):
#warning("Find a macOS navigation replacement")
            if let navigation = navigation {
                ModulesFactory.shared.makeAccountCreationModule(mode: mode, navigation: navigation)
            }
        }
    }
}
