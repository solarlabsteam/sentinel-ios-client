//
//  OnboardingViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 11.08.2021.
//

#if os(iOS)
import UIKit
#endif

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
    @Published private(set) var steps: [OnboardingStepModel]
    
    @Published private(set) var isLastPage: Bool = true
    @Published var currentPage = 0

    private var cancellables = Set<AnyCancellable>()

    init(model: OnboardingModel, router: Router) {
        self.model = model
        self.router = router

        self.steps = [
            .init(
                tag: 0,
                title: L10n.Onboarding.Title._1,
                imageName: Asset.Onboarding.first.name,
                description: L10n.Onboarding.Description._1
            ),
            .init(
                tag: 1,
                title: L10n.Onboarding.Title._2,
                imageName: Asset.Onboarding.second.name,
                description: L10n.Onboarding.Description._2
            ),
            .init(
                tag: 2,
                title: L10n.Onboarding.Title._3,
                imageName: Asset.Onboarding.third.name,
                description: L10n.Onboarding.Description._3
            )
        ]

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                }
            }
            .store(in: &cancellables)

        $currentPage
            .sink(
                receiveValue: { [weak self] in
                    guard let self = self else { return }
#if os(iOS)
                    UIImpactFeedbackGenerator.lightFeedback()
#endif
                    self.isLastPage = $0 == self.steps.count - 1
                }
            )
            .store(in: &cancellables)
    }

    func didTapCreateButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .createAccount(mode: .create))
    }

    func didTapImportButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .createAccount(mode: .restore))
    }

    func didTapNextButton() {
        guard currentPage < steps.count - 1 else {
            return
        }

        currentPage += 1
    }
}
