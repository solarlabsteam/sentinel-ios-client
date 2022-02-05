//
//  AccountInfoViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import AppKit
import Foundation
import FlagKit
import SentinelWallet
import Combine
import EFQRCode
import AlertToast

final class AccountInfoViewModel: ObservableObject {
    @Published private(set) var qrCode: ImageAsset.Image
    @Published private(set) var address: String
    @Published private(set) var balance: String?

    @Published var alertContent: (isShown: Bool, toast: AlertToast) = (false, AlertToast(type: .loading))
    
    private let model: AccountInfoModel
    private var cancellables = Set<AnyCancellable>()
    
    init(model: AccountInfoModel) {
        self.model = model
        
        // swiftlint:disable force_unwrapping
        
        let code = EFQRCode.generate(
            for: model.address,
            backgroundColor: CGColor.init(gray: 0, alpha: 0)
        )!
        
        self.qrCode = NSImage(cgImage: code, size: .init(width: 150, height: 150))
        
        // swiftlint:enable force_unwrapping
        
        self.address = model.address
        
        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.show(error: error)
                case let .update(balance):
                    self?.balance = balance
                }
            }
            .store(in: &cancellables)
        
        model.setInitialBalance()
        refresh()
    }
}

extension AccountInfoViewModel {
    // swiftlint:disable force_unwrapping
    var solarPayURL: URL {
        .init(string: "https://pay.solarlabs.ee/topup?currency=dvpn&wallet=\(address)")!
    }
    // swiftlint:enable force_unwrapping
    
    func refresh() {
        model.refresh()
    }
}

// MARK: - Buttons actions

extension AccountInfoViewModel {
    func didTapCopy() {
        alertContent = (
            true,
            AlertToast(type: .regular, title: L10n.AccountInfo.textCopied)
        )
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(model.address, forType: .string)
    }
}

extension AccountInfoViewModel {
    private func show(error: Error) {
        alertContent = (
            true,
            AlertToast(type: .error(NSColor.systemRed.asColor), title: error.localizedDescription)
        )
    }
}
