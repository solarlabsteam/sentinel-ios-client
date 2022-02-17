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
    case launch
}

final class AppStageSwitcherViewModel: ObservableObject {
    typealias Context = HasGeneralInfoStorage
    
    @Published private(set) var stage: AppStage
    private let context: Context

    init(stage: AppStage, context: CommonContext) {
        self.stage = stage
        self.context = context
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

extension AppStageSwitcherViewModel: LaunchViewModelDelegate {
    func dataLoaded() {
        stage = context.generalInfoStorage.didPassOnboarding() ? .home : .onboarding
    }
}
