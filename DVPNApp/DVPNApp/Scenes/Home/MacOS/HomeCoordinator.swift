//
//  HomeCoordinator.swift
//  DVPNApp
//
//  Created by Viktoriia Kostyleva on 11.11.2021.
//

import Cocoa
import SwiftUI

final class HomeCoordinator: CoordinatorType {
    private weak var window: NSWindow?

    private let context: HomeModel.Context

    init(context: HomeModel.Context, window: NSWindow) {
        self.context = context
        self.window = window
    }

    func start() {
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: asRouter())
        let view = HomeView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)

//        controller.makeNavigationBar(hidden: false, animated: false)
//        controller.title = L10n.Home.Node.title
        
        window?.contentView = controller

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
        guard let window = window else { return }
        switch event {
        case let .error(error):
#warning("handle error properly on macOS")
            log.error(error)
        case .accountInfo:
            log.debug("TODO macos implement accountInfo")
//            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: window)
        case let .details(node, isSubscribed):
            log.debug("TODO macos implement details")
//            ModulesFactory.shared.makeNodeDetailsModule(
//                for: navigation,
//                configuration: .init(node: node, isSubscribed: isSubscribed)
//            )
        case let .subscribe(node, delegate):
            log.debug("TODO macos implement subscribe")
//            ModulesFactory.shared.makePlansModule(node: node, delegate: delegate, for: navigation)
        case .sentinel:
            if let url = UserConstants.sentinelURL {
                NSWorkspace.shared.open(url)
            }
        case .solarLabs:
            if let url = UserConstants.solarLabsURL {
                NSWorkspace.shared.open(url)
            }
        case let .title(title):
            log.debug("TODO macos implement title")
        case let .dns(delegate, server):
            log.debug("TODO macos implement dns")
//            ModulesFactory.shared.makeDNSSettingsModule(delegate: delegate, server: server, for: navigation)
        case let .openNodes(continent, delegate):
            log.debug("TODO macos implement openNodes")
//            ModulesFactory.shared.makeAvailableNodesModule(
//                continent: continent, delegate: delegate, for: navigation
//            )
        }
    }
}
