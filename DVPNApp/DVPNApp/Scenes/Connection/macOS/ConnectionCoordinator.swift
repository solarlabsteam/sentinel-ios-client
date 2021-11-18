//
//  ConnectionCoordinator.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobeva on 12.11.2021.
//

import SwiftUI
import SentinelWallet

final class ConnectionCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?
    private let context: ConnectionModel.Context

    init(context: ConnectionModel.Context, navigation: NavigationHelper) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let homeModel = ConnectionModel(context: context)
        let homeViewModel = ConnectionViewModel(model: homeModel, router: asRouter())
        let homeView = ConnectionView(viewModel: homeViewModel)
        let controller = NSHostingView(rootView: homeView)
        navigation?.switchSubview(to: controller)
    }
}

extension ConnectionCoordinator: RouterType {
    func play(event: ConnectionViewModel.Route) {
//        guard let navigation = navigation else { return }
        switch event {
        case .error(let error):
#warning("handle error properly on macOS")
            log.error(error)
        case .warning(let error):
#warning("handle warning properly on macOS")
            log.error(error)
        case let .openPlans(node, delegate):
            log.debug("TODO macos implement openPlans")
//            ModulesFactory.shared.makePlansModule(node: node, delegate: delegate, for: navigation)
        case .accountInfo:
            log.debug("TODO macos implement accountInfo")
//            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case let .dismiss(isEnabled):
            log.debug("TODO macos implement dismiss")
//            setBackNavigationEnability(isEnabled: isEnabled)
        case .resubscribe(let completion):
            log.debug("TODO macos implement resubscribe")
        }
    }
}
