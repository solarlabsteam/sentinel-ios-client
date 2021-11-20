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
    private let server: DNSServerType
    private weak var delegate: DNSSettingsViewModelDelegate?

    init(
        context: DNSSettingsModel.Context,
        delegate: DNSSettingsViewModelDelegate?,
        server: DNSServerType,
        navigation: UINavigationController
    ) {
        self.context = context
        self.delegate = delegate
        self.server = server
        self.navigation = navigation
    }

    func start() {
        let model = DNSSettingsModel(context: context)
        let viewModel = DNSSettingsViewModel(model: model, server: server, delegate: delegate, router: asRouter())
        let view = DNSSettingsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        controller.modalPresentationStyle = .overFullScreen

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
