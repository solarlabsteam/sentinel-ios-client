//
//  DNSSettingsCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import UIKit
import SwiftUI
import SentinelWallet

final class DNSSettingsCoordinator: CoordinatorType {
    private weak var navigation: UINavigationController?
    private weak var rootController: UIViewController?

    private let context: DNSSettingsModel.Context
    private let servers: [DNSServerType]
    private weak var delegate: DNSSettingsViewModelDelegate?

    init(
        context: DNSSettingsModel.Context,
        delegate: DNSSettingsViewModelDelegate?,
        servers: [DNSServerType],
        navigation: UINavigationController
    ) {
        self.context = context
        self.delegate = delegate
        self.servers = servers
        self.navigation = navigation
    }

    func start() {
        let model = DNSSettingsModel(context: context)
        let viewModel = DNSSettingsViewModel(model: model, servers: servers, delegate: delegate, router: asRouter())
        let view = DNSSettingsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overCurrentContext

        rootController = controller

        navigation?.present(controller, animated: false)
    }
}

extension DNSSettingsCoordinator: RouterType {
    func play(event: DNSSettingsViewModel.Route) {
        switch event {
        case .close:
            navigation?.dismiss(animated: true)
        }
    }
}
