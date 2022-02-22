//
//  PlansModel.swift
//  SentinelDVPN
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Foundation
import Combine
import SentinelWallet

enum PlansModelEvent {
    case error(Error)
    case updatePayment(countryName: String, price: String, fee: Int)
    case processPayment(Result<TransactionResult, Error>)
    case addTokens
}

enum PlansModelError: LocalizedError {
    case paymentFailed

    var errorDescription: String? {
        switch self {
        case .paymentFailed:
            return L10n.Plans.Error.Payment.failed
        }
    }
}

final class PlansModel {
    typealias Context = HasSentinelService & HasWalletService & HasConnectionInfoStorage
    private let context: Context

    private let eventSubject = PassthroughSubject<PlansModelEvent, Never>()
    var eventPublisher: AnyPublisher<PlansModelEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var node: DVPNNodeInfo

    init(context: Context, node: DVPNNodeInfo) {
        self.context = context
        self.node = node
    }
}

extension PlansModel {
    var address: String {
        context.walletService.accountAddress
    }
    
    // swiftlint:disable force_unwrapping
    var solarPayURL: URL {
        .init(string: "https://pay.solarlabs.ee/topup?currency=dvpn&wallet=\(address)")!
    }
    
    func refresh() {
        $node.eraseToAnyPublisher()
            .map { [context] in
                PlansModelEvent.updatePayment(
                    countryName: $0.location.country,
                    price: $0.price,
                    fee: context.walletService.fee
                )
            }
            .subscribe(eventSubject)
            .store(in: &cancellables)
    }

    func checkBalanceAndSubscribe(deposit: CoinToken, plan: String, price: String) {
        let selectedPlan = SelectedPlan(node: node, deposit: deposit, planString: plan, price: price)
        context.walletService.fetchBalance { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.eventSubject.send(.processPayment(.failure(error)))
            case .success(let balances):
                let balance = balances
                    .first(where: { $0.denom == deposit.denom })
                
                guard let balance = balance,
                      Int(balance.amount) ?? 0 >= (Int(deposit.amount) ?? 0 + self.context.walletService.fee) else {
                    self.eventSubject.send(.addTokens)
                    return
                }

                self.subscribe(to: selectedPlan)
            }
        }
    }
}

// MARK: - Private

extension PlansModel {
    private func show(error: Error) {
        log.error(error)
        eventSubject.send(.error(error))
    }

    private func subscribe(to selectedPlan: SelectedPlan) {
        context.sentinelService.subscribe(to: node.address, deposit: selectedPlan.deposit) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.eventSubject.send(.processPayment(.failure(error)))
            case .success(let response):
                guard response.isSuccess else {
                    self?.eventSubject.send(.processPayment(.failure(PlansModelError.paymentFailed)))
                    return
                }
                self?.context.connectionInfoStorage.set(lastSelectedNode: selectedPlan.node.address)
                self?.context.connectionInfoStorage.set(shouldConnect: true)
                self?.eventSubject.send(.processPayment(.success(response)))
            }
        }
    }
}
