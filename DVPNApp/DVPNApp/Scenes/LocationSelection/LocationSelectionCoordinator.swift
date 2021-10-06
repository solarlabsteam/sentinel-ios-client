//
//  LocationSelectionCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 03.10.2021.
//

import UIKit
import SwiftUI
import SwiftMessages

private struct Constants {
    let sentinelURL = URL(string: "https://sentinel.co/")
}

private let constants = Constants()

final class LocationSelectionCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: LocationSelectionModel.Context

    init(context: LocationSelectionModel.Context, navigation: UINavigationController) {
        self.context = context
        self.navigation = navigation
    }

    func start() {
        let model = LocationSelectionModel(context: context)
        let viewModel = LocationSelectionViewModel(model: model, router: asRouter())
        let view = LocationSelectionView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        rootController = controller
        navigation?.viewControllers = [controller]

        controller.makeNavigationBar(hidden: false, animated: false)
        controller.title = L10n.LocationSelection.Node.title

        navigation?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Navigation.account.image,
            style: .plain,
            target: viewModel,
            action: #selector(viewModel.didTapAccountInfoButton)
        )
    }
}

extension LocationSelectionCoordinator: RouterType {
    func play(event: LocationSelectionViewModel.Route) {
        guard let navigation = navigation else { return }
        switch event {
        case let .error(error):
            show(message: error.localizedDescription)
        case .accountInfo:
            ModulesFactory.shared.makeAccountInfoModule(for: navigation)
        case .connect:
            ModulesFactory.shared.makeConnectionModule(for: navigation)
        case let .details(node, isSubscribed):
            ModulesFactory.shared.makeNodeDetailsModule(for: navigation, configuration: .init(node: node, isSubscribed: isSubscribed))
        case let .subscribe(node):
            ModulesFactory.shared.makePlansModule(node: node, for: navigation)
        case .sentinel:
            if let url = constants.sentinelURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case let .title(title):
            rootController?.title = title
        }
    }
}
