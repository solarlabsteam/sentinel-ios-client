//
//  ModulesFactory+macOS.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 09.11.2021.
//

import Cocoa
import SwiftUI
import SentinelWallet

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
    func detectStartModule(for navigation: NavigationHelper) {
        context.nodesService.loadAllNodes { [weak self] result in
            if case let .success(nodes) = result {
                self?.context.nodesService.loadNodesInfo(for: nodes)
            }
        }

        guard context.generalInfoStorage.didPassOnboarding() else {
            makeOnboardingModule(for: navigation)
            return
        }

        context.preloadService.loadData { [weak self] in
            self?.makeHomeModule(for: navigation)
        }
    }

    func makeOnboardingModule(for navigation: NavigationHelper) {
        OnboardingCoordinator(context: context, navigation: navigation).start()
    }
    
    func makeAccountCreationModule(mode: CreationMode, navigation: NavigationHelper) {
        AccountCreationCoordinator(context: context, mode: mode, navigation: navigation).start()
    }
    
    func makeHomeModule(for navigation: NavigationHelper) {
        if !context.generalInfoStorage.didPassOnboarding() {
            context.generalInfoStorage.set(didPassOnboarding: true)
        }
        HomeCoordinator(context: context, navigation: navigation).start()
    }
    
    func makeConnectionModule(for navigation: NavigationHelper) {
        ConnectionCoordinator(context: context, navigation: navigation).start()
    }
    
    func makeAvailableNodesModule(
        continent: Continent,
        delegate: PlansViewModelDelegate?,
        for navigation: NavigationHelper
    ) {
        AvailableNodesCoordinator(
            context: context,
            delegate: delegate,
            navigation: navigation,
            continent: continent
        ).start()
    }
    
    func makeAccountInfoModule(for navigation: NavigationHelper) {
        AccountInfoCoordinator(context: context, navigation: navigation).start()
    }

    func makePlansModule(
        node: DVPNNodeInfo,
        delegate: PlansViewModelDelegate?,
        for navigation: NavigationHelper
    ) {
        PlansCoordinator(context: context, navigation: navigation, node: node, delegate: delegate).start()
    }
}

/// Scenes previews
extension ModulesFactory {
    func getOnboardingScene() -> OnboardingView {
        let coordinator = OnboardingCoordinator(
            context: context,
            navigation: NavigationHelper(window: NSWindow())
        ).asRouter()
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, router: coordinator)
        let view = OnboardingView(viewModel: viewModel)

        return view
    }
    
    func getAccountCreationScene(mode: CreationMode = .create) -> AccountCreationView {
        let coordinator = AccountCreationCoordinator(
            context: context,
            mode: mode,
            navigation: NavigationHelper(window: NSWindow())
        ).asRouter()
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: coordinator)
        let view = AccountCreationView(viewModel: viewModel)

        return view
    }
    
    func getHomeScene() -> HomeView {
        let coordinator = HomeCoordinator(
            context: context,
            navigation: NavigationHelper(window: NSWindow())
        ).asRouter()
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: coordinator)
        let view = HomeView(viewModel: viewModel)

        return view
    }
    
    func getConnectionScene() -> ConnectionView {
        let coordinator = ConnectionCoordinator(context: context, navigation: NavigationHelper(window: NSWindow()))
        let viewModel = ConnectionViewModel(
            model: ConnectionModel(context: context),
            router: coordinator.asRouter()
        )
        let view = ConnectionView(viewModel: viewModel)

        return view
    }
    
    func getAccountInfoScene() -> AccountInfoView {
        let coordinator = AccountInfoCoordinator(
            context: context,
            navigation: NavigationHelper(window: NSWindow())
        ).asRouter()
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model, router: coordinator)
        let view = AccountInfoView(viewModel: viewModel)

        return view
    }
}
