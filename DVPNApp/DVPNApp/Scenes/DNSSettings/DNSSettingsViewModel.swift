//
//  DNSSettingsViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import Combine

final class DNSSettingsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router
    
    enum Route {
        case close
    }
    
    private weak var delegate: DNSSettingsViewModelDelegate?
    
    private let model: DNSSettingsModel
    
    @Published private(set) var items: [DNSSettingsRowViewModel]
    
    init(model: DNSSettingsModel, server: DNSServerType, delegate: DNSSettingsViewModelDelegate?, router: Router) {
        self.model = model
        self.delegate = delegate
        self.router = router
        
        items = DNSServerType.allCases.map { .init(type: $0, isSelected: $0 == server) }
    }
    
    func toggleSelection(with server: DNSServerType) {
        guard let index = items.firstIndex(where: { $0.type == server }), !items[index].isSelected else { return }
        
        items.indices.forEach { items[$0].isSelected = false }
        items[index].isSelected = true
    }
    
    func didTapClose() {
        let server = items.first(where: { $0.isSelected }).map { $0.type } ?? .default
        model.save(server: server)
        delegate?.update(to: server)
        
        router.play(event: .close)
    }
}

// MARK: - Buttons actions

extension DNSSettingsViewModel {
    func didTapCrossButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .close)
    }
}
