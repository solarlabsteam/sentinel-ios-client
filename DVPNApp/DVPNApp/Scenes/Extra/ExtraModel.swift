//
//  ExtraModel.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 20.11.2021.
//

import Foundation
import Combine

enum ExtraModelEvent {
    case select(server: DNSServerType)
}

final class ExtraModel {
    typealias Context = HasSentinelService & HasDNSServersStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<ExtraModelEvent, Never>()
    var eventPublisher: AnyPublisher<ExtraModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }
    
    func refreshDNS() {
        eventSubject.send(.select(server: context.dnsServersStorage.selectedDNS()))
    }
}
