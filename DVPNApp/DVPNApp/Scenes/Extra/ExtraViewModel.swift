//
//  ExtraViewModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 20.11.2021.
//

import Foundation
import SentinelWallet
import Combine
import UIKit.UIImage
import NetworkExtension

final class ExtraViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case sentinel
        case solarLabs
        case exidio
        case dns(DNSSettingsViewModelDelegate?, DNSServerType)
    }
    
    private let model: ExtraModel
    private var cancellables = Set<AnyCancellable>()
    
    @Published var server: DNSServerType = .default

    init(model: ExtraModel, router: Router) {
        self.model = model
        self.router = router

        handeEvents()

        model.refreshDNS()
    }
}

// MARK: - DNSSettingsViewModelDelegate

extension ExtraViewModel: DNSSettingsViewModelDelegate {
    func update(to server: DNSServerType) {
        self.server = server
    }
}

// MARK: - Buttons actions

extension ExtraViewModel {
    func openMore() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .sentinel)
    }

    func openSolarLabs() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .solarLabs)
    }
    
    func openExidio() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .exidio)
    }

    func openDNSServersSelection() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .dns(self, server))
    }
}

extension ExtraViewModel {
    private func handeEvents() {
        model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .select(server):
                    self?.update(to: server)
                }
            }
            .store(in: &cancellables)
    }
}
