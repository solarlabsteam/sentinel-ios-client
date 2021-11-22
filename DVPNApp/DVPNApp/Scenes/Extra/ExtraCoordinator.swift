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
    let exidioURL = URL(string: "http://exidio.co")
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
        controller.title = L10n.Extras.title
    }
}

extension ExtraCoordinator: RouterType {
    func play(event: ExtraViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case .sentinel:
            open(url: constants.sentinelURL)
        case .solarLabs:
            open(url: constants.solarLabsURL)
        case .exidio:
            open(url: constants.exidioURL)
        case let .dns(delegate, server):
            ModulesFactory.shared.makeDNSSettingsModule(delegate: delegate, server: server, for: navigation)
        }
    }
}

extension ExtraCoordinator {
    private func open(url: URL?) {
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
