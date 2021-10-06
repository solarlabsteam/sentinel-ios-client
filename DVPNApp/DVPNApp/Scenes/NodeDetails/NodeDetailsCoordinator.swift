//
//  NodeDetailsCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 04.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages
import SentinelWallet

final class NodeDetailsCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: NodeDetailsModel.Context
    
    struct Configuration {
        let node: Node
        let isSubscribed: Bool
    }
    private let configuration: Configuration

    init(context: NodeDetailsModel.Context, navigation: UINavigationController, configuration: Configuration) {
        self.context = context
        self.navigation = navigation
        self.configuration = configuration
    }

    func start() {
        let model = NodeDetailsModel(context: context, node: configuration.node, isSubscribed: configuration.isSubscribed)
        let viewModel = NodeDetailsViewModel(model: model, router: asRouter())
        let view = NodeDetailsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)
        
        controller.makeNavigationBar(hidden: false, animated: false)
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Navigation.account.image,
            style: .plain,
            target: viewModel,
            action: #selector(viewModel.didTapAccountButton)
        )
    }
}

extension NodeDetailsCoordinator: RouterType {
    func play(event: NodeDetailsViewModel.Route) {
        guard let navigation = navigation else { return }
        
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case .account:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case let .subscribe(node: nodeInfo):
            ModulesFactory.shared.makePlansModule(node: nodeInfo, for: navigation)
        case .connect:
            ModulesFactory.shared.makeHomeModule(for: navigation)
        }
    }
}
