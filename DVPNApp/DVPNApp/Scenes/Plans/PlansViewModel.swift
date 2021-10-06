//
//  PlansViewModel.swift
//  DVPNApp
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import UIKit
import FlagKit
import SentinelWallet
import Combine
import GRPC

final class PlansViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case addTokensAlert
        case accountInfo
        case subscribe(node: String, completion: (Bool) -> Void)
        case openConnection
        case close
    }
    
    private let stepGB = 1
    private var fee: Int = 0
    private var price: Int = 0
    
    @Published private(set) var selectedLocationName: String
    
    @Published private(set) var prettyTokesToSpend: String = "0"
    
    @Published private(set) var gbToBuy: Int {
        didSet {
            prettyTokesToSpend = formatter.string(from: NSNumber(value: Double(tokesToSpend) * 0.000001)) ?? "\(tokesToSpend)"
        }
    }

    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let model: PlansModel
    
    private let formatter = NumberFormatter()
    
    init(model: PlansModel, router: Router) {
        self.model = model
        self.router = router
        
        selectedLocationName = ""
        gbToBuy = 1
        
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .updatePayment(countryName, price, fee):
                    self?.updatePayment(countryName: countryName, price: price, fee: fee)
                case let .processPayment(result):
                    self?.isLoading = false
                    switch result {
                    case .failure(let error):
                        self?.show(error: error)
                    case .success(let info):
                        self?.router.play(event: .openConnection)
                    }
                case .addTokens:
                    router.play(event: .addTokensAlert)
                case .openConnection:
                    router.play(event: .openConnection)
                }
            }
            .store(in: &cancellables)

        self.model.refresh()
    }
    
    func togglePlus() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard gbToBuy < 100 else {
            return
        }
        gbToBuy += stepGB
    }
    
    func toggleMinus() {
        UIImpactFeedbackGenerator.lightFeedback()
        guard gbToBuy > 1 else {
            return
        }
        gbToBuy -= stepGB
    }
    
    var tokesToSpend: Int {
        gbToBuy * price + fee
    }
    
    func didTapSubscribe() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(
            event: .subscribe(node: selectedLocationName) { [weak self] result in
                guard let self = self, result else {
                    return
                }
                self.isLoading = true
                self.model.checkBalanceAndSubscribe(
                    deposit: .init(denom: "udvpn", amount: "\(self.price * self.gbToBuy)"),
                    plan: String(format: "%.1f", self.gbToBuy) + L10n.Common.gb,
                    price: self.prettyTokesToSpend
                )
            }
        )
    }
    
    // TODO: @tori
    @objc
    func didTapCrossButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .close)
    }
}

extension PlansViewModel {
    private func show(error: Error) {
        isLoading = false
        guard let grpcError = error as? GRPC.GRPCError.RPCTimedOut else {
            router.play(event: .error(error))
            return
        }

        router.play(event: .error(grpcError))
    }

    private func updatePayment(countryName: String, price: String, fee: Int) {
        self.selectedLocationName = countryName
        self.fee = fee
        self.price = PriceFormatter.rawFormat(price: price).price
        self.gbToBuy = gbToBuy
    }
}
