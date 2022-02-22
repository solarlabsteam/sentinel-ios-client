//
//  PlansViewModel.swift
//  SentinelDVPN
//
//  Created by Aleksandr Litreev on 12.08.2021.
//

import Cocoa
import FlagKit
import SentinelWallet
import Combine
import GRPC
import AlertToast
import SwiftUI

private struct Constants {
    let stepGB = 1
    let maxAllowedGB = 100
    let minAllowedGB = 1
}
private let constants = Constants()

final class PlansViewModel: ObservableObject {
    private let model: PlansModel

    private var fee: Int = 0
    private var price: Int = 0
    
    @Published private(set) var selectedLocationName: String
    @Published var prettyTokesToSpend: String = "0"

    @Published private(set) var gbToBuy: Int {
        didSet {
            prettyTokesToSpend = "\(PriceFormatter.fullFormat(amount: tokesToSpend)) DVPN"
        }
    }

    @Published var isLoading: Bool = false
    @Published var alertToastContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    @Published var alertContent: (isShown: Bool, alert: Alert) = (
        false,
        Alert(title: Text(""), message: nil, dismissButton: nil)
    )
    
    @Binding var isPresented: Bool

    private var cancellables = Set<AnyCancellable>()
    private let formatter = NumberFormatter()
    
    init(model: PlansModel, isPresented: Binding<Bool>) {
        self.model = model
        self._isPresented = isPresented
        
        selectedLocationName = ""
        gbToBuy = 1

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
                    if case let .failure(error) = result {
                        self?.show(error: error)
                    }
                    if case .success = result {
                        self?.isPresented = false
                    }
                case .addTokens:
                    self?.showAddTokens()
                }
            }
            .store(in: &cancellables)

        self.model.refresh()
    }
}

// MARK: - Counter

extension PlansViewModel {
    func togglePlus() {
        guard gbToBuy < constants.maxAllowedGB else {
            return
        }
        gbToBuy += constants.stepGB
    }
    
    func toggleMinus() {
        guard gbToBuy > constants.minAllowedGB else {
            return
        }
        gbToBuy -= constants.stepGB
    }
    
    var tokesToSpend: Int {
        gbToBuy * price + fee
    }
}

// MARK: - Buttons actions

extension PlansViewModel {
    func didTapSubscribe() {
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = true
            self.model.checkBalanceAndSubscribe(
                deposit: .init(denom: "udvpn", amount: "\(self.price * self.gbToBuy)"),
                plan: String(format: "%.1f", self.gbToBuy) + L10n.Common.gb,
                price: self.prettyTokesToSpend
            )
        }
        
        alertContent = (
            true,
            Alert(
                title: Text(L10n.Plans.Subscribe.title(selectedLocationName)),
                primaryButton: .default(
                    Text(L10n.Common.yes),
                    action: completion
                ),
                secondaryButton: .destructive(
                    Text(L10n.Common.cancel),
                    action: {}
                )
            )
        )
    }
}

// MARK: - Private

extension PlansViewModel {
    private func show(error: Error) {
        isLoading = false
        guard let grpcError = error as? GRPC.GRPCError.RPCTimedOut else {
            show(unwrappedError: error)
            return
        }

        show(unwrappedError: grpcError)
    }

    private func show(unwrappedError: Error) {
        alertToastContent = (
            true,
            AlertToast(
                type: .error(NSColor.systemRed.asColor),
                title: unwrappedError.localizedDescription
            )
        )
    }

    private func updatePayment(countryName: String, price: String, fee: Int) {
        self.selectedLocationName = countryName
        self.fee = fee
        self.price = PriceFormatter.rawFormat(price: price).price
        self.gbToBuy = gbToBuy
    }

    private func showAddTokens() {
        let completion = { [weak self] in
            guard let self = self else { return }
            NSWorkspace.shared.open(self.model.solarPayURL)
            self.isPresented = false
        }
        
        alertContent = (
            true,
            Alert(
                title: Text(L10n.Plans.AddTokens.title),
                message: Text(L10n.Plans.AddTokens.subtitle),
                primaryButton: .default(
                    Text(L10n.Common.yes),
                    action: completion
                ),
                secondaryButton: .destructive(
                    Text(L10n.Common.cancel),
                    action: {}
                )
            )
        )
    }
}
