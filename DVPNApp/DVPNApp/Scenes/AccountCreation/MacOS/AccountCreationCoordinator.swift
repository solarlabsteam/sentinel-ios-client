//
//  AccountCreationCoordinator.swift
//  SentinelDVPNmacOS
//
//  Created by Lika Vorobeva on 10.11.2021.
//

import Foundation
import Cocoa
import SwiftUI

final class AccountCreationCoordinator: CoordinatorType {
    private weak var window: NSWindow?

    private let context: AccountCreationModel.Context
    private let mode: CreationMode

    init(context: AccountCreationModel.Context, mode: CreationMode, window: NSWindow) {
        self.context = context
        self.window = window
        self.mode = mode
    }

    func start() {
        let model = AccountCreationModel(context: context)
        let viewModel = AccountCreationViewModel(model: model, mode: mode, router: asRouter())
        let view = AccountCreationView(viewModel: viewModel)
        let controller = NSHostingView(rootView: view)
        window?.contentView = controller
    }
}

extension AccountCreationCoordinator: RouterType {
    func play(event: AccountCreationViewModel.Route) {
    }
}
