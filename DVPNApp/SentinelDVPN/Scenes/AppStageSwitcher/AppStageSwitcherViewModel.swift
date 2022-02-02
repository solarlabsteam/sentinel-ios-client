//
//  AppStageSwitcherViewModel.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import Foundation
enum AppStage {
    case onboarding
    case accountCreation(mode: CreationMode)
    case home
}

final class AppStageSwitcherViewModel: ObservableObject {
    @Published private(set) var stage: AppStage

    init(stage: AppStage) {
        self.stage = stage
    }
}

extension AppStageSwitcherViewModel: OnboardingViewModelDelegate {
    func didFinish(with mode: CreationMode) {
        stage = .accountCreation(mode: mode)
    }
}

extension AppStageSwitcherViewModel: AccountCreationViewModelDelegate {
    func openNodes() {
        stage = .home
    }
}
