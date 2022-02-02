//
//  AppStageSwitcherView.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import SwiftUI

struct AppStageSwitcherView: View {
    @ObservedObject private var viewModel: AppStageSwitcherViewModel

    init(viewModel: AppStageSwitcherViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.stage {
        case .onboarding:
            ModulesFactory.shared.makeOnboardingScene(delegate: viewModel)
        case let .accountCreation(mode):
            ModulesFactory.shared.makeAccountCreationScene(with: mode, delegate: viewModel)
        case .home:
            ModulesFactory.shared.makeNodeSelectionModule()
        }
    }
}
