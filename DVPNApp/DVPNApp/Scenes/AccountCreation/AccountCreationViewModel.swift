//
//  AccountCreationViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

import UIKit
import Combine
import HDWallet

enum CreationMode {
    case restore
    case create

    var title: String {
        switch self {
        case .create:
            return L10n.AccountCreation.Create.title
        case .restore:
            return L10n.AccountCreation.Import.title
        }
    }

    var buttonTitle: String {
        switch self {
        case .create:
            return L10n.AccountCreation.Create.button
        case .restore:
            return L10n.AccountCreation.Import.button
        }
    }
}

final class AccountCreationViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case privacy
        case openNodes
        case title(String)
        case info(String)
    }

    private let model: AccountCreationModel
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var mode: CreationMode
    @Published private(set) var address: String?
    @Published var mnemonic: [String] = Array(repeating: "", count: 24)
    @Published var isEnabled: Bool = false

    @Published private(set) var isTermsChecked: Bool = false

    init(model: AccountCreationModel, mode: CreationMode, router: Router) {
        self.model = model
        self.router = router
        self.mode = mode

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .address(address):
                    self?.address = address
                case let .mnemonic(mnemonic):
                    self?.mnemonic = mnemonic
                case let .mode(mode):
                    self?.mode = mode
                    self?.isEnabled = mode == .restore

                    router.play(event: .title(mode.title))
                case .updateWallet:
                    router.play(event: .openNodes)
                }
            }
            .store(in: &cancellables)

        model.change(to: mode)
    }
}

// MARK: - Buttons actions

extension AccountCreationViewModel {
    func didTapMnemonicActionButton() {
        UIImpactFeedbackGenerator.lightFeedback()
        if mode == .restore {
            didTapPasteMnemonic()
        } else {
            didTapCopyMnemonic()
        }
    }

    func didTapCopyAddress() {
        guard let address = address else { return }
        router.play(event: .info(L10n.AccountCreation.Copied.address))
        
        UIImpactFeedbackGenerator.lightFeedback()
        UIPasteboard.general.string = address
    }
    
    func didTapMainButton() {
        UIImpactFeedbackGenerator.lightFeedback()

        switch mode {
        case .restore:
            model.saveWallet(mnemonic: mnemonic)
        case .create:
            if !isTermsChecked {
                router.play(event: .error(AccountCreationModelError.termsUnchecked))
                return
            }

            router.play(event: .openNodes)
        }
    }

    func didCheckTerms() {
        UIImpactFeedbackGenerator.lightFeedback()
        isTermsChecked = !isTermsChecked
    }

    func didTapTerms() {
        UIImpactFeedbackGenerator.lightFeedback()
        router.play(event: .privacy)
    }

    func didTapChangeMode() {
        UIImpactFeedbackGenerator.lightFeedback()
        let newMode: CreationMode = mode == .create ? .restore : .create

        model.change(to: newMode)
    }
}

// MARK: - Private methods

extension AccountCreationViewModel {
    private func didTapPasteMnemonic() {
        UIPasteboard.general.string?.splitToArray(separator: " ").prefix(24).enumerated().forEach { index, value in
            mnemonic[index] = value
        }

        model.check(mnemonic: mnemonic)
    }
    
    private func didTapCopyMnemonic() {
        router.play(event: .info(L10n.AccountCreation.Copied.mnemonic))
        
        UIImpactFeedbackGenerator.lightFeedback()
        UIPasteboard.general.string = mnemonic.joined(separator: " ")
    }
}
