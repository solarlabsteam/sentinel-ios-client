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
    case info(Error)
    case purchaseCompleted
    case packages([Package])
}

enum PurchasesModelError: LocalizedError {
    case purchaseCancelled
    
    var errorDescription: String? {
        switch self {
        case .purchaseCancelled:
            return L10n.Purchases.Warning.cancelled
        }
    }
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
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else { return }
            guard let offerings = offerings else {
                if let error = error {
                    log.error(error)
                    self.eventSubject.send(.error(error))
                }
                return
            }
            
            log.debug(offerings)
            
            let availablePackages = offerings.all.flatMap { $0.value.availablePackages }
            self.eventSubject.send(.packages(availablePackages))
        }
    }
    
    func purchase(package: Package) {
        Purchases.shared.purchase(package: package) { [weak self] (transaction, purchaserInfo, error, userCancelled) in
            guard !userCancelled else {
                self?.eventSubject.send(.info(PurchasesModelError.purchaseCancelled))
                return
            }
            
            guard let error = error else {
                self?.eventSubject.send(.purchaseCompleted)
                return
            }
            
            log.error(error)
            self?.eventSubject.send(.error(error))
        }
    }
}

