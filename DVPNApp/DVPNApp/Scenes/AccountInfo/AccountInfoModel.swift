//
//  AccountInfoModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import Combine

private struct Constants {
    let denom = "udvpn"
}

private let constants = Constants()

enum AccountInfoModelEvent {
    case update(balance: String)
    case priceInfo(currentPrice: String, lastPriceUpdateInfo: String)
    case error(Error)
}

final class AccountInfoModel {
    typealias Context = HasStorage & HasWalletService
    private let context: Context

    private let eventSubject = PassthroughSubject<AccountInfoModelEvent, Never>()
    var eventPublisher: AnyPublisher<AccountInfoModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(context: Context) {
        self.context = context
    }
}

extension AccountInfoModel {
    var address: String {
        context.walletService.accountAddress
    }
    
    func refresh() {
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                log.error(error)
                self.eventSubject.send(.error(error))
            case .success(let balances):
                guard let balance = balances.first(where: { $0.denom == constants.denom }) else {
                    self.eventSubject.send(.update(balance: "0"))
                    return
                }

                let prettyBalance = PriceFormatter.fullFormat(amount: balance.amount, denom: "")

                self.eventSubject.send(.update(balance: prettyBalance))
            }
        }
        
        loadPriceInfo()
    }
}

extension AccountInfoModel {
    private func loadPriceInfo() {
        // Warning: We use only udvpn for this moment.
        context.walletService.getPrices(for: "udvpn") { [weak self] result in
            switch result {
            case .failure(let error):
                log.error(error)
                self?.eventSubject.send(.error(error))
            case .success(let exchangeRates):
                let exchangeRate = exchangeRates.first
                
                guard let exchangeRate = exchangeRate, let priceInfo = exchangeRate.prices.first else {
                    log.error("Loaded price is nil")
                    return
                }
                
                // TODO: We need enum of denoms in wallet repo
                let denom = priceInfo.currency == "usd" ? "$" : "?"
                
                let roundedPrice = String(priceInfo.currentPrice.roundToDecimal(3))
                
                let roundedPercent = String(priceInfo.dailyPriceChangePercentage.roundToDecimal(2))
                
                self?.eventSubject.send(
                    .priceInfo(
                        currentPrice: "\(denom) \(roundedPrice)",
                        lastPriceUpdateInfo: "\(roundedPercent)% (24h)"
                    )
                )
            }
        }
    }
}
