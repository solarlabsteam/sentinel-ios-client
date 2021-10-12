//
//  DNSSettingsViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import UIKit
import Combine

protocol DNSSettingsViewModelDelegate: AnyObject {
    func update(to servers: [DNSServerType])
}

final class DNSSettingsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case close
    }

    private weak var delegate: DNSSettingsViewModelDelegate?

    private let model: DNSSettingsModel

    @Published private(set) var items: [DNSSettingsRowViewModel]

    init(model: DNSSettingsModel, servers: [DNSServerType], delegate: DNSSettingsViewModelDelegate?, router: Router) {
        self.model = model
        self.delegate = delegate
        self.router = router

        items = DNSServerType.allCases.map { .init(type: $0, isSelected: servers.contains($0)) }
    }

    func toggleSelection(with server: DNSServerType) {
        guard let index = items.firstIndex(where: { $0.type == server }) else { return }

        if items[index].isSelected, items.filter({ $0.isSelected }).count == 1 { return }
        items[index].isSelected = !items[index].isSelected
    }

    func didTapClose() {
        let servers = items.filter({ $0.isSelected }).map { $0.type }
        model.save(servers: servers)
        delegate?.update(to: servers)
        
        router.play(event: .close)
    }
}

// MARK: - Buttons actions

extension DNSSettingsViewModel {
    func didTapCrossButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .close)
    }
}
