//
//  HomeCoordinator.swift
//  DVPNApp
//
//  Created by Viktoriia Kostyleva on 11.11.2021.
//

import Cocoa
import SwiftUI

final class HomeCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: HomeModel.Context

    init(context: HomeModel.Context, navigation: NavigationHelper) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: asRouter())
        let view = HomeView(viewModel: viewModel)
        let container = NSHostingView(rootView: view)

//        controller.makeNavigationBar(hidden: false, animated: false)
//        controller.title = L10n.Home.Node.title
        
        navigation?.push(view: container, clearStack: true)

//        navigation?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
//            image: Asset.Navigation.account.image,
//            style: .plain,
//            target: viewModel,
//            action: #selector(viewModel.didTapAccountInfoButton)
//        )
    }
}

extension HomeCoordinator: RouterType {
    func play(event: HomeViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            showErrorAlert(message: error.localizedDescription)
        case .accountInfo:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            log.debug("TODO macos implement details")
//            ModulesFactory.shared.makeNodeDetailsModule(
//                for: navigation,
//                configuration: .init(node: node, isSubscribed: isSubscribed)
//            )
        case let .subscribe(node, delegate):
            ModulesFactory.shared.makePlansModule(node: node, delegate: delegate, for: navigation)
        case .sentinel:
            if let url = UserConstants.sentinelURL {
                NSWorkspace.shared.open(url)
            }
        case .solarLabs:
            if let url = UserConstants.solarLabsURL {
                NSWorkspace.shared.open(url)
            }
        case .title:
            break
        case let .dns(delegate, server):
            ModulesFactory.shared.makeDNSSettingsModule(delegate: delegate, server: server, for: navigation)
        case let .openNodes(continent, delegate):
            ModulesFactory.shared.makeAvailableNodesModule(
                continent: continent, delegate: delegate, for: navigation
            )
        }
    }
}
