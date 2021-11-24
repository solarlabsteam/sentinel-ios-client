//
//  PurchasesViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import UIKit
import Combine

final class PurchasesViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case terms
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
                    self?.router.play(event: .error(error))
                }
            }
            .store(in: &cancellables)

        updatePayment()
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
        isLoading = true
#warning("TODO purchase")
    }
    
    func didTapTerms() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .terms)
    }
}

extension PurchasesViewModel {
    private func updatePayment() {
        let optionsUnits = [1, 5, 10, 50, 100, 500]

        options = optionsUnits.map {
            PurchaseOptionViewModel(amount: $0, price: "$\(Double($0) - 0.01)", isSelected: $0 == 1)
        }

        selectedOption = options.first
    }
}
