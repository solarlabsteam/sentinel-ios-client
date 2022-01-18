//
//  ModulesFactory.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 17.06.2021.
//

private struct Constants {
    let key = "OnboardingPassed"
}

private let constants = Constants()

import UIKit
import SentinelWallet
import SwiftUI
import Combine

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
    func detectStartModule(for window: UIWindow) {
        context.nodesService.loadAllNodes { [weak self] result in
            if case let .success(nodes) = result {
                self?.context.nodesService.loadNodesInfo(for: nodes)
            }
        }
        
        guard context.generalInfoStorage.didPassOnboarding() else {
            makeOnboardingModule(for: window)
            return
        }
        
        makeEmptyModule(for: window)
        
        context.preloadService.loadData { [weak self] in
            self?.makeHomeModule(for: window)
        }
    }

    func makeOnboardingModule(for window: UIWindow) {
        let navigation = UINavigationController()
        window.rootViewController = navigation

        OnboardingCoordinator(context: context, navigation: navigation, window: window).start()
    }

    func makeAccountCreationModule(mode: CreationMode, for navigation: UINavigationController, window: UIWindow) {
        AccountCreationCoordinator(context: context, mode: mode, navigation: navigation, window: window).start()
    }

    func makeConnectionModule(for navigation: UINavigationController) {
        ConnectionCoordinator(context: context, navigation: navigation).start()
    }

    func makeHomeModule(for window: UIWindow) {
        let navigation = UINavigationController()
        window.rootViewController = navigation

        if !context.generalInfoStorage.didPassOnboarding() {
            context.generalInfoStorage.set(didPassOnboarding: true)
        }

        HomeCoordinator(context: context, navigation: navigation).start()
    }
    
    func makeEmptyModule(for window: UIWindow) {
        let storyboard = UIStoryboard(name: "EmptyScreen", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "EmptyViewController")
        
        window.rootViewController = controller
    }
    
    func makeNodeDetailsModule(
        for navigation: UINavigationController,
        configuration: NodeDetailsCoordinator.Configuration
    ) {
        NodeDetailsCoordinator(context: context, navigation: navigation, configuration: configuration).start()
    }

    func makeAccountInfoModule(for navigation: UINavigationController) {
        AccountInfoCoordinator(context: context, navigation: navigation).start()
    }

    func makePlansModule(
        node: DVPNNodeInfo,
        delegate: PlansViewModelDelegate?,
        for navigation: UINavigationController
    ) {
        PlansCoordinator(context: context, navigation: navigation, node: node, delegate: delegate).start()
    }

    func makeDNSSettingsModule(
        delegate: DNSSettingsViewModelDelegate?,
        server: DNSServerType,
        for navigation: UINavigationController
    ) {
        DNSSettingsCoordinator(context: context, delegate: delegate, server: server, navigation: navigation).start()
    }
    
    func makeAvailableNodesModule(
        continent: Continent,
        delegate: PlansViewModelDelegate?,
        for navigation: UINavigationController
    ) {
        AvailableNodesCoordinator(
            context: context,
            delegate: delegate,
            navigation: navigation,
            continent: continent
        ).start()
    }
}

/// Scenes previews
extension ModulesFactory {
    func getConnectionScene() -> ConnectionView {
        let coordinator = ConnectionCoordinator(context: context, navigation: UINavigationController())
        let viewModel = ConnectionViewModel(
            model: ConnectionModel(context: context),
            router: coordinator.asRouter()
        )
        let view = ConnectionView(viewModel: viewModel)

        return view
    }

    func getOnboardingScene() -> OnboardingView {
        let coordinator = OnboardingCoordinator(
            context: context,
            navigation: UINavigationController(),
            window: UIWindow()
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
            navigation: UINavigationController(),
            window: UIWindow()
        ).asRouter()
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: coordinator)
        let view = AccountCreationView(viewModel: viewModel)

        return view
    }

    func getHomeScene() -> HomeView {
        let coordinator = HomeCoordinator(
            context: context,
            navigation: UINavigationController()
        ).asRouter()
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: coordinator)
        let view = HomeView(viewModel: viewModel)

        return view
    }

    func getAccountInfoScene() -> AccountInfoView {
        let coordinator = AccountInfoCoordinator(context: context, navigation: UINavigationController()).asRouter()
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model, router: coordinator)
        let view = AccountInfoView(viewModel: viewModel)

        return view
    }

    func getDNSSettingsScene(delegate: DNSSettingsViewModelDelegate? = nil) -> DNSSettingsView {
        let coordinator = DNSSettingsCoordinator(
            context: context,
            delegate: delegate,
            server: .default,
            navigation: UINavigationController()
        ).asRouter()
        let model = DNSSettingsModel(context: context)
        let viewModel = DNSSettingsViewModel(model: model, server: .default, delegate: delegate, router: coordinator)
        let view = DNSSettingsView(viewModel: viewModel)

        return view
    }

//    func getPlansScene() -> PlansView {
//        let coordinator = PlansCoordinator(context: context, navigation: UINavigationController(), node: nil)
//        let model = PlansModel(context: context, node: nil)
//        let viewModel = PlansViewModel(model: model, router: coordinator.asRouter())
//        let view = PlansView(viewModel: viewModel)
//
//        return view
//    }
}
