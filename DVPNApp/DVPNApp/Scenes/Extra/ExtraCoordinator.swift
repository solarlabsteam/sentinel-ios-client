//
//  ExtraCoordinator.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 20.11.2021.
//

import UIKit
import SwiftUI

private struct Constants {
    let sentinelURL = URL(string: "https://sentinel.co/")
    let solarLabsURL = URL(string: "http://labs.solar")
}

private let constants = Constants()

final class ExtraCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: ExtraModel.Context

    init(context: ExtraModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = ExtraModel(context: context)
        let viewModel = ExtraViewModel(model: model, router: asRouter())
        let view = ExtraView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Extra.title
    }
}

extension ExtraCoordinator: RouterType {
    func play(event: ExtraViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case .sentinel:
            if let url = constants.sentinelURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case .solarLabs:
            if let url = constants.solarLabsURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case let .dns(delegate, server):
            ModulesFactory.shared.makeDNSSettingsModule(delegate: delegate, server: server, for: navigation)
        }
    }
}
