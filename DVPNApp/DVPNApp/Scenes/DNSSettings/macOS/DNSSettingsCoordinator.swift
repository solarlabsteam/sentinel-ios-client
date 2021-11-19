//
//  DNSSettingsCoordinator.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 18.11.2021.
//

import Foundation
import SwiftUI
import SentinelWallet

final class DNSSettingsCoordinator: CoordinatorType {
    private weak var navigation: NavigationHelper?

    private let context: DNSSettingsModel.Context
    private let server: DNSServerType
    private weak var delegate: DNSSettingsViewModelDelegate?

    init(
        context: DNSSettingsModel.Context,
        delegate: DNSSettingsViewModelDelegate?,
        server: DNSServerType,
        navigation: NavigationHelper
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
        let container = NSHostingView(rootView: view)
        navigation?.present(view: container)
    }
}

extension DNSSettingsCoordinator: RouterType {
    func play(event: DNSSettingsViewModel.Route) {
        switch event {
        case .close:
            navigation?.pop()
        }
    }
}
