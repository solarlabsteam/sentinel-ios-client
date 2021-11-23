//
//  PurchasesModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import Foundation
import Combine
import SentinelWallet
import RevenueCat

enum PurchasesModelEvent {
    case error(Error)
}

enum PurchasesModelError: LocalizedError {
}

final class PurchasesModel {
    typealias Context = NoContext
    private let context: Context

    private let eventSubject = PassthroughSubject<PurchasesModelEvent, Never>()
    var eventPublisher: AnyPublisher<PurchasesModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }

    func refresh() {
        Purchases.shared.getOfferings { (offerings, error) in
            log.debug(offerings)
            log.error(error)
            if let offerings = offerings {

              // Display current offering with offerings.current
          }
        }
    }
}

