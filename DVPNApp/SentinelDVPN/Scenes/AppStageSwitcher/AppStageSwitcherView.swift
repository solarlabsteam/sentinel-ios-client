//
//  AppStageSwitcherView.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 02.02.2022.
//

import SwiftUI

struct AppStageSwitcherView: View {
    @ObservedObject private var viewModel: AppStageSwitcherViewModel
    @State private var showAccountPopover = false

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
            NavigationView {
                ModulesFactory.shared.makeConnectionScene()
                ModulesFactory.shared.makeNodeSelectionModule()
            }
            .background(Asset.Colors.accentColor.color.asColor)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAccountPopover.toggle() }) {
                        Asset.Navigation.account.image.asImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .popover(isPresented: $showAccountPopover, arrowEdge: .bottom) {
                        ModulesFactory.shared.makeAccountInfoScene()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 25, height: 25)
                }
            }
        case .launch:
            ModulesFactory.shared.makeLaunchView(delegate: viewModel)
        }
    }
}
