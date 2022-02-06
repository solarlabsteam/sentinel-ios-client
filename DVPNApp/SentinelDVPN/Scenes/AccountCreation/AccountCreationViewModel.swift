//
//  AccountCreationViewModel.swift
//  SentinelDVPN
//
//  Created by Lika Vorobeva on 04.10.2021.
//

import Cocoa
import SwiftUI
import Combine
import HDWallet
import Foundation
import AlertToast

protocol AccountCreationViewModelDelegate: AnyObject {
    func openNodes()
}

final class AccountCreationViewModel: ObservableObject {
    private let model: AccountCreationModel
    private weak var delegate: AccountCreationViewModelDelegate?
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var mode: CreationMode
    @Published private(set) var address: String?
    @Published var mnemonic: [String] = Array(repeating: "", count: 24)
    @Published var isEnabled: Bool = false

    @Published private(set) var isTermsChecked: Bool = false

    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))

    init(model: AccountCreationModel, mode: CreationMode, delegate: AccountCreationViewModelDelegate?) {
        self.model = model
        self.mode = mode
        self.delegate = delegate
        
        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .address(address):
                    self?.address = address
                case let .mnemonic(mnemonic):
                    self?.mnemonic = mnemonic
                case let .mode(mode):
                    self?.mode = mode
                    self?.isEnabled = mode == .restore
                case .updateWallet:
                    self?.delegate?.openNodes()
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

        alertContent = (
            true,
            AlertToast(type: .regular, title: L10n.AccountCreation.Copied.address)
        )

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(address, forType: .string)
    }
    
    func didTapMainButton() {
        switch mode {
        case .restore:
            model.saveWallet(mnemonic: mnemonic)
        case .create:
            if !isTermsChecked {
                show(error: AccountCreationModelError.termsUnchecked)
                return
            }

            delegate?.openNodes()
        }
    }

    func didCheckTerms() {
        isTermsChecked = !isTermsChecked
    }
    
    func didTapChangeMode() {
        let newMode: CreationMode = mode == .create ? .restore : .create

        model.change(to: newMode)
    }
}

// MARK: - Private methods

extension AccountCreationViewModel {
    private func show(error: Error) {
        alertContent = (
            true,
            AlertToast(type: .error(NSColor.systemRed.asColor), title: error.localizedDescription)
        )
    }

    private func didTapPasteMnemonic() {
        let pasteboard = NSPasteboard.general.string(forType: .string)
        pasteboard.splitToArray(separator: " ").prefix(24).enumerated().forEach { index, value in
            mnemonic[index] = value
            
            model.check(mnemonic: mnemonic)
        }
    }
    
    private func didTapCopyMnemonic() {
        alertContent = (
            true,
            AlertToast(type: .regular, title: L10n.AccountCreation.Copied.mnemonic)
        )
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(mnemonic.joined(separator: " "), forType: .string)
    }
}
