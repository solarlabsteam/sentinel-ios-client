//
//  AccountInfoModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import Combine
import SentinelWallet

enum AccountInfoModelEvent {
    case update(balance: String)
    case set(exchangeRates: [ExchangeRates])
    case error(Error)
}

final class AccountInfoModel {
    typealias Context = HasWalletService & HasUserService
    private let context: Context

    private let eventSubject = PassthroughSubject<AccountInfoModelEvent, Never>()
    var eventPublisher: AnyPublisher<AccountInfoModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()

    init(context: Context) {
        self.context = context
    }
}

extension AccountInfoModel {
    var address: String {
        context.walletService.accountAddress
    }
    
    func setInitialBalance() {
        eventSubject.send(.update(balance: context.userService.balance))
    }
    
    func refresh() {
        context.userService.loadBalance()
            .eraseToAnyPublisher()
            .sink(
                receiveCompletion: { [weak self] result in
                    if case let .failure(error) = result {
                        self?.eventSubject.send(.error(error))
                    }
                },
                receiveValue: { [weak self] balance in
                    self?.eventSubject.send(.update(balance: balance))
                }
            ).store(in: &cancellables)
        
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
                self?.eventSubject.send(.set(exchangeRates: exchangeRates))
            }
        }
    }
}
