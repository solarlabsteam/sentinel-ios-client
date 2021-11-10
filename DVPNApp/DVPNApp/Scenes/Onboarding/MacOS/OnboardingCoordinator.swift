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
    private weak var window: NSWindow?

    private let context: OnboardingModel.Context

    init(context: OnboardingModel.Context, window: NSWindow) {
        self.context = context
        self.window = window
    }

    func start() {
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: asRouter())
        let view = OnboardingView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        window?.contentView = controller
    }
}

extension OnboardingCoordinator: RouterType {
    func play(event: OnboardingViewModel.Route) {
        switch event {
        case let .createAccount(mode):
#warning("Find a macOS navigation replacement")
            if let window = window {
                ModulesFactory.shared.makeAccountCreationModule(mode: mode, window: window)
            }
        }
    }
}
