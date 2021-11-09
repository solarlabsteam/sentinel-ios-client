//
//  PlansCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.08.2021.
//

import SwiftUI
import SentinelWallet

final class PlansCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: PlansModel.Context
    private let node: DVPNNodeInfo
    private weak var delegate: PlansViewModelDelegate?

    init(
        context: PlansModel.Context,
        navigation: UINavigationController,
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
        let controller = UIHostingController(rootView: addTokensView)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overCurrentContext

        rootController = controller

        navigation?.present(controller, animated: false)
    }
}

// MARK: - Handle events

extension PlansCoordinator: RouterType {
    func play(event: PlansViewModel.Route) {
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case let .addTokensAlert(completion: completion):
            showNotEnoughTokensAlert(completion: completion)
        case let .subscribe(node, completion):
            showSubscribeAlert(name: node, completion: completion)
        case .accountInfo:
            navigation?.dismiss(animated: true)
            if let navigation = navigation {
                ModulesFactory.shared.makeAccountInfoModule(for: navigation)
            }
        case .close:
            navigation?.dismiss(animated: true)
        }
    }
}

// MARK: - Private

extension PlansCoordinator {
    private func showSubscribeAlert(
        name: String,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(
            title: L10n.Plans.Subscribe.title(name),
            message: nil,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { _ in
#if os(iOS)
            UIImpactFeedbackGenerator.lightFeedback()
#endif
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
#if os(iOS)
            UIImpactFeedbackGenerator.lightFeedback()
#endif
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }

    private func showNotEnoughTokensAlert(completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: L10n.Plans.AddTokens.title,
            message: L10n.Plans.AddTokens.subtitle,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { _ in
#if os(iOS)
            UIImpactFeedbackGenerator.lightFeedback()
#endif
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
#if os(iOS)
            UIImpactFeedbackGenerator.lightFeedback()
#endif
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }
}
