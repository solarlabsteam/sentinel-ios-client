//
//  NodeDetailsCoordinator.swift
//  SentinelDVPNmacOS
//
//  Created by Victoria Kostyleva on 18.11.2021.
//

import SwiftUI
import SentinelWallet

final class NodeDetailsCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?
    
    private let context: NodeDetailsModel.Context
    
    struct Configuration {
        let node: SentinelNode
        let isSubscribed: Bool
    }
    private let configuration: Configuration

    init(context: NodeDetailsModel.Context, navigation: NavigationHelper, configuration: Configuration) {
        self.context = context
        self.navigation = navigation
        self.configuration = configuration
    }

    func start() {
        let model = NodeDetailsModel(
            context: context,
            node: configuration.node,
            isSubscribed: configuration.isSubscribed
        )
        let viewModel = NodeDetailsViewModel(model: model, router: asRouter())
        let view = NodeDetailsView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        navigation?.push(view: controller)
    }
}

extension NodeDetailsCoordinator: RouterType {
    func play(event: NodeDetailsViewModel.Route) {
        guard let navigation = navigation else { return }
        
        switch event {
        case let .error(error):
            showErrorAlert(message: error.localizedDescription)
        case .account:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case let .subscribe(node, delegate):
            ModulesFactory.shared.makePlansModule(node: node, delegate: delegate, for: navigation)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case .dismiss:
            navigation.popToRoot()
        }
    }
}

