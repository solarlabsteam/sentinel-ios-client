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
        let container = NSHostingView(rootView: view)
        navigation?.push(view: container)
        
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
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
#warning("handle error properly on macOS")
            log.error(error)
        case let .subscribe(nodeInfo):
            ModulesFactory.shared.makePlansModule(node: nodeInfo, delegate: delegate, for: navigation)
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

