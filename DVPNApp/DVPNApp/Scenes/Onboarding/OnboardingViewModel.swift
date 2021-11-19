//
//  OnboardingViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 11.08.2021.
//

import UIKit
import Combine
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case createAccount(mode: CreationMode)
    }

    private let model: OnboardingModel
    @Published private(set) var step: OnboardingStepModel

    init(model: OnboardingModel, router: Router) {
        self.model = model
        self.router = router

        self.step =
            .init(
                tag: 0,
                title: L10n.Onboarding.title,
                imageName: Asset.Launch.exidiolBig.name,
                description: L10n.Onboarding.description
            )
    }

    func didTapCreateButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .createAccount(mode: .create))
    }

    func didTapImportButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .createAccount(mode: .restore))
    }
}
