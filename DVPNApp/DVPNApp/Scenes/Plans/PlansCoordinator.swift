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

    init(context: PlansModel.Context, navigation: UINavigationController, node: DVPNNodeInfo) {
        self.context = context
        self.navigation = navigation
        self.node = node
    }

    func start() {
        let addTokensModel = PlansModel(context: context, node: node)
        let addTokensViewModel = PlansViewModel(model: addTokensModel, router: asRouter())
        let addTokensView = PlansView(viewModel: addTokensViewModel)
        let controller = UIHostingController(rootView: addTokensView)
        rootController = controller
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
        navigation?.present(navigationController, animated: true)
        navigation?.modalPresentationStyle = .overFullScreen
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "multiply"),
            style: .plain,
            target: addTokensViewModel,
            action: #selector(addTokensViewModel.didTapCrossButton)
        )

        controller.makeNavigationBar(hidden: false, animated: false)
    }
}

// MARK: - Handle events

extension PlansCoordinator: RouterType {
    func play(event: PlansViewModel.Route) {
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .addTokensAlert:
            showNotEnoughTokensAlert()
        case let .subscribe(node, completion):
            showSubscribeAlert(name: node, completion: completion)
        case .openConnection:
            navigation?.popToRootViewController(animated: true)
        case .accountInfo:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation!)
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
            UIImpactFeedbackGenerator.lightFeedback()
            completion(true)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
            completion(false)
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }

    private func showNotEnoughTokensAlert() {
        let alert = UIAlertController(
            title: L10n.Plans.AddTokens.title,
            message: L10n.Plans.AddTokens.subtitle,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: L10n.Common.yes, style: .default) { [weak self] _ in
            self?.navigation?.dismiss(animated: true)
            UIImpactFeedbackGenerator.lightFeedback()
            self?.play(event: .accountInfo)
        }

        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .destructive) { _ in
            UIImpactFeedbackGenerator.lightFeedback()
        }

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        rootController?.present(alert, animated: true, completion: nil)
    }
}
