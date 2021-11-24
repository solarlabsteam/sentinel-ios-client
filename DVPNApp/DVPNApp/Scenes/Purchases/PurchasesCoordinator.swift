//
//  PurchasesCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.10.2021.
//

import UIKit
import SwiftUI
import SentinelWallet

private struct Constants {
    let privacyURL = URL(string: "https://dvpn.exidio.co/legal/tos")
}

private let constants = Constants()

final class PurchasesCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: PurchasesModel.Context

    init(context: PurchasesModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = PurchasesModel(context: context)
        let viewModel = PurchasesViewModel(model: model, router: asRouter())
        let view = PurchasesView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.pushViewController(controller, animated: true)
        controller.hidesBottomBarWhenPushed = true
        controller.title = L10n.Purchases.title
    }
}

extension PurchasesCoordinator: RouterType {
    func play(event: PurchasesViewModel.Route) {
        switch event {
        case .error(let error):
            show(message: error.localizedDescription)
        case .info(let error):
            show(message: error.localizedDescription, theme: .info)
        case .purchaseCompleted:
            show(message: L10n.Purchases.Info.completed, theme: .success)
            navigation?.popViewController(animated: true)
        case .terms:
            if let url = constants.privacyURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}
