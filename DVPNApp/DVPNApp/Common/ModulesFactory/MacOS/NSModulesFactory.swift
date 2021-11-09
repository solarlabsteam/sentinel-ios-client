//
//  ModulesFactory+macOS.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Cocoa
import SwiftUI

final class ModulesFactory {
    private(set) static var shared = ModulesFactory()
    private let context: CommonContext

    private init() {
        context = ContextBuilder().buildContext()
    }

    func resetWalletContext() {
        context.resetWalletContext()
    }
}

extension ModulesFactory {
    func makeOnboardingModule(for window: NSWindow) {
        OnboardingCoordinator(context: context, window: window).start()
    }
}

/// Scenes previews
extension ModulesFactory {
    func getOnboardingScene() -> OnboardingView {
        let coordinator = OnboardingCoordinator(
            context: context,
            window: NSWindow()
        ).asRouter()
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: coordinator)
        let view = OnboardingView(viewModel: viewModel)

        return view
    }
}
