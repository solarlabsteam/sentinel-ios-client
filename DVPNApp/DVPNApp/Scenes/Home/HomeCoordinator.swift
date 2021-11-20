//
//  HomeCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 03.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

private struct Constants {
    let sentinelURL = URL(string: "https://sentinel.co/")
    let solarLabsURL = URL(string: "http://labs.solar")
}

private let constants = Constants()

final class HomeCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: HomeModel.Context

    init(context: HomeModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = HomeModel(context: context)
        let viewModel = HomeViewModel(model: model, router: asRouter())
        let view = HomeView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.Home.Node.title
    }
}

extension HomeCoordinator: RouterType {
    func play(event: HomeViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            ModulesFactory.shared.makeNodeDetailsModule(
                for: navigation,
                configuration: .init(node: node, isSubscribed: isSubscribed)
            )
        case let .subscribe(node, delegate):
            ModulesFactory.shared.makePlansModule(node: node, delegate: delegate, for: navigation)
        case .sentinel:
            if let url = constants.sentinelURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case .solarLabs:
            if let url = constants.solarLabsURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case let .title(title):
            rootController?.title = title
        case let .dns(delegate, server):
            ModulesFactory.shared.makeDNSSettingsModule(delegate: delegate, server: server, for: navigation)
        case let .openNodes(continent, delegate):
            ModulesFactory.shared.makeAvailableNodesModule(
                continent: continent, delegate: delegate, for: navigation
            )
        }
    }
}
