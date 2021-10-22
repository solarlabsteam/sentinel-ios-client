//
//  DNSSettingsModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import Foundation
import Combine
import SentinelWallet

enum DNSSettingsModelEvent { }

final class DNSSettingsModel {
    typealias Context = HasStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<DNSSettingsModelEvent, Never>()
    var eventPublisher: AnyPublisher<DNSSettingsModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }

    func save(server: DNSServerType) {
        context.storage.set(dns: server)
    }
}
