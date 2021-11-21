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
    }
}
