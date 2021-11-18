//
//  PlansCoordinator.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobyeva on 18.11.2021.
//

import SwiftUI
import SentinelWallet

final class PlansCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: PlansModel.Context
    private let node: DVPNNodeInfo
    private weak var delegate: PlansViewModelDelegate?

    init(
        context: PlansModel.Context,
        navigation: NavigationHelper,
        node: DVPNNodeInfo,
        delegate: PlansViewModelDelegate?
    ) {
        self.context = context
        self.navigation = navigation
        self.node = node
        self.delegate = delegate
    }

    func start() {
        let addTokensModel = PlansModel(context: context, node: node)
        let addTokensViewModel = PlansViewModel(model: addTokensModel, router: asRouter(), delegate: delegate)
        let addTokensView = PlansView(viewModel: addTokensViewModel)
        let container = NSHostingView(rootView: addTokensView)
        navigation?.present(view: container)
    }
}

// MARK: - Handle events

extension PlansCoordinator: RouterType {
    func play(event: PlansViewModel.Route) {
        switch event {
        case let .error(error):
#warning("handle error properly on macOS")
            log.error(error)
        case let .addTokensAlert(completion: completion):
#warning("add alerts on macOS")
        case let .subscribe(node, completion):
#warning("add alerts on macOS")
        case .accountInfo:
            if let navigation = navigation {
                ModulesFactory.shared.makeAccountInfoModule(for: navigation)
            }
        case .close:
            navigation?.pop()
        }
    }
}
