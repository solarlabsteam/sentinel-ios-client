//
//  OnboardingViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobeva on 11.08.2021.
//

import Combine
import SwiftUI

struct OnboardingStepModel {
    let tag: Int
    let title: String
    let image: Image
    let description: String
}

private struct Constants {
    let steps: [OnboardingStepModel] = [
        .init(
            tag: 0,
            title: L10n.Onboarding.Title._1,
            image: Asset.Onboarding.first.image.asImage,
            description: L10n.Onboarding.Description._1
        ),
        .init(
            tag: 1,
            title: L10n.Onboarding.Title._2,
            image: Asset.Onboarding.second.image.asImage,
            description: L10n.Onboarding.Description._2
        ),
        .init(
            tag: 2,
            title: L10n.Onboarding.Title._3,
            image: Asset.Onboarding.third.image.asImage,
            description: L10n.Onboarding.Description._3
        )
    ]
}

private let constants = Constants()

protocol OnboardingViewModelDelegate: AnyObject {
    func didFinish(with mode: CreationMode)
}

final class OnboardingViewModel: ObservableObject {
    private let model: OnboardingModel

    @Published private(set) var title = constants.steps[0].title
    @Published private(set) var image = constants.steps[0].image
    @Published private(set) var description = constants.steps[0].description

    @Published var currentPage = 0
    @Published var isLastPage: Bool = false

    private weak var delegate: OnboardingViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()

    init(model: OnboardingModel, delegate: OnboardingViewModelDelegate?) {
        self.model = model
        self.delegate = delegate

        $currentPage
            .sink(
                receiveValue: { [weak self] in
                    guard let self = self else { return }
                    self.isLastPage = $0 == constants.steps.count - 1
                    self.update(to: $0)
                }
            )
            .store(in: &cancellables)
    }
}

extension OnboardingViewModel {
    func didTapCreateButton() {
        delegate?.didFinish(with: .create)
    }

    func didTapImportButton() {
        delegate?.didFinish(with: .restore)
    }

    func didTapNextButton() {
        guard currentPage < constants.steps.count - 1 else {
            return
        }

        currentPage += 1
    }
}

extension OnboardingViewModel {
    private func update(to page: Int) {
        title = constants.steps[page].title
        image = constants.steps[page].image
        description = constants.steps[page].description
    }
}
