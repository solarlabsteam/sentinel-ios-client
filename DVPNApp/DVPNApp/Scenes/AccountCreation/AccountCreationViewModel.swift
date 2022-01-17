//
//  AccountCreationViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif
import Combine
import HDWallet
import Foundation

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
#if os(iOS)
            .receive(on: DispatchQueue.main)
#endif
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
        if mode == .restore {
            didTapPasteMnemonic()
        } else {
            didTapCopyMnemonic()
        }
    }

    func didTapCopyAddress() {
        guard let address = address else { return }
        router.play(event: .info(L10n.AccountCreation.Copied.address))

    #if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
        UIPasteboard.general.string = address
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(address, forType: .string)
 #endif
    }
    
    func didTapMainButton() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif

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
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        isTermsChecked = !isTermsChecked
    }

    func didTapTerms() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        router.play(event: .privacy)
    }

    func didTapChangeMode() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        let newMode: CreationMode = mode == .create ? .restore : .create

        model.change(to: newMode)
    }
}

// MARK: - Private methods

extension AccountCreationViewModel {
    private func didTapPasteMnemonic() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
        let pasteboard = UIPasteboard.general.string
#elseif os(macOS)
        let pasteboard = NSPasteboard.general.string(forType: .string)
#endif
        pasteboard.splitToArray(separator: " ").prefix(24).enumerated().forEach { index, value in
            mnemonic[index] = value
            
            model.check(mnemonic: mnemonic)
        }
    }
    
    private func didTapCopyMnemonic() {
        router.play(event: .info(L10n.AccountCreation.Copied.mnemonic))
        
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
        UIPasteboard.general.string = mnemonic.joined(separator: " ")
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(mnemonic.joined(separator: " "), forType: .string)
#endif
    }
}
