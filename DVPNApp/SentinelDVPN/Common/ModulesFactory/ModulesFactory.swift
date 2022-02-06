//
//  ModulesFactory+macOS.swift
//  SentinelDVPN
//
//  Created by Victoria Kostyleva on 18.01.2022.
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
    
    func makeStatusMenu() -> StatusMenu {
        StatusMenu(context: context)
    }
}

extension ModulesFactory {
    func detectStartModule() -> AppStageSwitcherView {
        #warning("Preloading data slows app start down, some placeholder is needed")
//        context.nodesService.loadAllNodes { [weak self] result in
//            if case let .success(nodes) = result {
//                self?.context.nodesService.loadNodesInfo(for: nodes)
//            }
//        }
//
//        context.preloadService.loadData {
//            log.debug("Preloaded data.")
//        }

        let stage: AppStage = context.generalInfoStorage.didPassOnboarding() ? .home : .onboarding

        let viewModel = AppStageSwitcherViewModel(stage: stage)
        let view = AppStageSwitcherView(viewModel: viewModel)

        return view
    }

    func makeOnboardingScene(delegate: OnboardingViewModelDelegate? = nil) -> OnboardingView {
        let model = OnboardingModel(context: context)
        let viewModel = OnboardingViewModel(model: model, delegate: delegate)
        let view = OnboardingView(viewModel: viewModel)

        return view
    }

    func makeAccountCreationScene(
        with mode: CreationMode,
        delegate: AccountCreationViewModelDelegate? = nil
    ) -> AccountCreationView {
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, delegate: delegate)
        let view = AccountCreationView(viewModel: viewModel)

        return view
    }
    
    func makeNodeSelectionModule() -> NodeSelectionView {
        if !context.generalInfoStorage.didPassOnboarding() {
            context.generalInfoStorage.set(didPassOnboarding: true)
        }
        
        let model = NodeSelectionModel(context: context)
        let viewModel = NodeSelectionViewModel(model: model)
        let view = NodeSelectionView(viewModel: viewModel)

        return view
    }
    
    func makeAccountInfoScene() -> AccountInfoView {
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model)
        let view = AccountInfoView(viewModel: viewModel)
        
        return view
    }
    
    func makeConnectionScene() -> ConnectionView {
        let model = ConnectionModel(context: context)
        let viewModel = ConnectionViewModel(model: model)
        let view = ConnectionView(viewModel: viewModel)
        
        return view
    }

    func makeAvailableNodesScene(for continent: Continent) -> AvailableNodesView {
        let model = AvailableNodesModel(context: context, continent: continent)
        let viewModel = AvailableNodesViewModel(continent: continent, model: model)
        let view = AvailableNodesView(viewModel: viewModel)

        return view
    }
    
    func makeNodeDetailsScene(node: SentinelNode, isSubscribed: Bool) -> NodeDetailsView {
        let model = NodeDetailsModel(
            context: context,
            node: node,
            isSubscribed: isSubscribed
        )
        let viewModel = NodeDetailsViewModel(model: model)
        let view = NodeDetailsView(viewModel: viewModel)
        
        return view
    }
    
    func makePlansScene(nodeInfo: DVPNNodeInfo, delegate: PlansViewModelDelegate?) -> PlansView {
        let model = PlansModel(context: context, node: nodeInfo)
        let viewModel = PlansViewModel(model: model, delegate: delegate)
        let view = PlansView(viewModel: viewModel)
        
        return view
    }
}

// MARK: - Scenes previews

extension ModulesFactory {
    func getNodeSelectionScene() -> NodeSelectionView {
        let model = NodeSelectionModel(context: context)
        let viewModel = NodeSelectionViewModel(model: model)
        let view = NodeSelectionView(viewModel: viewModel)

        return view
    }
    
    func getAccountInfoScene() -> AccountInfoView {
        let model = AccountInfoModel(context: context)
        let viewModel = AccountInfoViewModel(model: model)
        let view = AccountInfoView(viewModel: viewModel)

        return view
    }
    
    func getConnectionScene() -> ConnectionView {
        let model = ConnectionModel(context: context)
        let viewModel = ConnectionViewModel(model: model)
        let view = ConnectionView(viewModel: viewModel)
        
        return view
    }
}
