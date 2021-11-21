//
//  AccountInfoViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

import Foundation
import FlagKit
import SentinelWallet
import Combine
import UIKit.UIImage
import EFQRCode

final class AccountInfoViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case info(String)
    }
    
    @Published private(set) var qrCode: UIImage
    @Published private(set) var address: String
    @Published private(set) var balance: String?

    private let model: AccountInfoModel
    private var cancellables = Set<AnyCancellable>()

    init(model: AccountInfoModel, router: Router) {
        self.model = model
        self.router = router
        
        // swiftlint:disable force_unwrapping
        self.qrCode = UIImage(
            cgImage: EFQRCode.generate(
                for: model.address,
                backgroundColor: CGColor.init(gray: 0, alpha: 0)
            )!
        )
        // swiftlint:enable force_unwrapping
        
        self.address = model.address

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
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
        router.play(event: .info(L10n.AccountInfo.textCopied))
        
        UIImpactFeedbackGenerator.lightFeedback()
        UIPasteboard.general.string = model.address
    }
    
    func didTapShare() {
        UIImpactFeedbackGenerator.lightFeedback()
        let activityVC = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
    }
}
