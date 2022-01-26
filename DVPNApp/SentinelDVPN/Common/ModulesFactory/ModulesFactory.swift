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
}

extension ModulesFactory {
//    func detectStartModule(for navigation: NavigationHelper, window: NSWindow) {
//        self.window = window
//
//        context.nodesService.loadAllNodes { [weak self] result in
//            if case let .success(nodes) = result {
//                self?.context.nodesService.loadNodesInfo(for: nodes)
//            }
//        }
//
//        guard context.generalInfoStorage.didPassOnboarding() else {
//            makeOnboardingModule(for: navigation)
//            return
//        }
//
//        context.preloadService.loadData { [weak self] in
//            self?.makeHomeModule(for: navigation)
//        }
//    }
    
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
    
    func getNodeDetailsScene(node: SentinelNode, isSubscribed: Bool) -> NodeDetailsView {
        let model = NodeDetailsModel(
            context: context,
            node: node,
            isSubscribed: isSubscribed
        )
        let viewModel = NodeDetailsViewModel(model: model)
        let view = NodeDetailsView(viewModel: viewModel)
        
        return view
    }
}
