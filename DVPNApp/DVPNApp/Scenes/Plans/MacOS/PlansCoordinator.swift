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
            showErrorAlert(message: error.localizedDescription)
        case let .addTokensAlert(completion: completion):
            showNotEnoughTokensAlert(completion: completion)
        case let .subscribe(node, completion):
            showSubscribeAlert(name: node, completion: completion)
        case .accountInfo:
            navigation?.pop()
            if let navigation = navigation {
                ModulesFactory.shared.makeAccountInfoModule(for: navigation)
            }
        case .close:
            navigation?.pop()
        }
    }
}

// MARK: - Private

extension PlansCoordinator {
    private func showSubscribeAlert(
        name: String,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = L10n.Plans.Subscribe.title(name)
        alert.alertStyle = .informational
        
        alert.addButton(withTitle: L10n.Common.yes)
        alert.addButton(withTitle: L10n.Common.cancel)
        
        let modalResult = alert.runModal() == .alertFirstButtonReturn
        completion(modalResult)
    }

    private func showNotEnoughTokensAlert(completion: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = L10n.Plans.AddTokens.title
        alert.informativeText = L10n.Plans.AddTokens.subtitle
        alert.alertStyle = .informational
        
        alert.addButton(withTitle: L10n.Common.yes)
        alert.addButton(withTitle: L10n.Common.cancel)
        
        let modalResult = alert.runModal() == .alertFirstButtonReturn
        completion(modalResult)
    }
}
