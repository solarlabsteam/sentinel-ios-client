//
//  AvailableNodesCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 12.11.2021.
//

import SwiftUI

final class AvailableNodesCoordinator: CoordinatorType {
    private let context: AvailableNodesModel.Context
    private weak var delegate: PlansViewModelDelegate?
    private weak var navigation: NavigationHelper?
    private let continent: Continent

    init(
        context: AvailableNodesModel.Context,
        delegate: PlansViewModelDelegate?,
        navigation: NavigationHelper,
        continent: Continent
    ) {
        self.context = context
        self.delegate = delegate
        self.navigation = navigation
        self.continent = continent
    }

    func start() {
        let model = AvailableNodesModel(context: context, continent: continent)
        let viewModel = AvailableNodesViewModel(continent: continent, model: model, router: asRouter())
        let view = AvailableNodesView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        navigation?.switchSubview(to: controller)
        
#warning("add buttons on macOS")
//        controller.makeNavigationBar(hidden: false, animated: false)
        
//        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: Asset.Navigation.account.image,
//            style: .plain,
//            target: viewModel,
//            action: #selector(viewModel.didTapAccountInfoButton)
//        )
    }
}

// MARK: - Events handling

extension AvailableNodesCoordinator: RouterType {
    func play(event: AvailableNodesViewModel.Route) {
        switch event {
        case let .error(error):
            showErrorAlert(message: error.localizedDescription)
        case let .subscribe(nodeInfo):
            log.debug("TODO macos implement openPlans")
//            ModulesFactory.shared.makePlansModule(node: nodeInfo, delegate: delegate, for: navigation)
        case .connect:
            log.debug("TODO macos implement")
//            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            log.debug("TODO macos implement")
//            ModulesFactory.shared.makeNodeDetailsModule(
//                for: navigation,
//                configuration: .init(node: node, isSubscribed: isSubscribed)
//            )
        case .accountInfo:
            log.debug("TODO macos implement")
//            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        }
    }
}

