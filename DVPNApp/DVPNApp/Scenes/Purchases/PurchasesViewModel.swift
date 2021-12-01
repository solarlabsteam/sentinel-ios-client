//
//  PurchasesViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import UIKit
import Combine
import RevenueCat

final class PurchasesViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case info(Error)
        case purchaseCompleted
        case terms
        case back(isEnabled: Bool)
    }

    private let model: PurchasesModel
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var options: [PurchaseOptionViewModel] = []
    @Published private(set)var selectedOption: PurchaseOptionViewModel?
    @Published var isLoading: Bool = false

    init(model: PurchasesModel, router: Router) {
        self.model = model
        self.router = router

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.updateState(isLoading: false)
                    self?.router.play(event: .error(error))
                case let .info(error):
                    self?.updateState(isLoading: false)
                    self?.router.play(event: .info(error))
                case .purchaseCompleted:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self?.updateState(isLoading: false)
                        self?.router.play(event: .purchaseCompleted)
                    }
                case let .packages(packages):
                    self?.update(packages: packages)
                }
            }
            .store(in: &cancellables)

        self.model.refresh()
    }

    func togglePurchase(vm: PurchaseOptionViewModel) {
        UIImpactFeedbackGenerator.lightFeedback()
        selectedOption = vm
        guard let index = options.firstIndex(where: { $0.amount == vm.amount }), !options[index].isSelected else { return }

        options.indices.forEach { options[$0].isSelected = false }
        options[index].isSelected = true
    }

    func didTapBuy() {
        UIImpactFeedbackGenerator.lightFeedback()
        updateState(isLoading: true)
        
        guard let package = selectedOption?.package else {
            return
        }
        
        model.purchase(package: package)
    }
    
    func didTapTerms() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .terms)
    }
}

extension PurchasesViewModel {
    private func update(packages: [Package]) {
        guard !packages.isEmpty else { return }
        
        options = packages.map {
            PurchaseOptionViewModel(
                package: $0,
                amount: Int.parse(from: $0.identifier) ?? 1,
                price: $0.localizedPriceString,
                isSelected: false
            )
        }

        options[0].isSelected = true
        selectedOption = options.first
    }

    private func updateState(isLoading: Bool) {
        self.isLoading = isLoading
        router.play(event: .back(isEnabled: !isLoading))
    }
}
