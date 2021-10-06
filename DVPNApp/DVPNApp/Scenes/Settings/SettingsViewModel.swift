//
//  SettingsViewModel.swift
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

final class SettingsViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
    }
    
    @Published private(set) var qrCode: UIImage
    @Published private(set) var address: String
    @Published private(set) var balance: String?
    @Published private(set) var currentPrice: String?
    @Published private(set) var lastPriceUpdateInfo: String?

    private let model: SettingsModel
    private var cancellables = Set<AnyCancellable>()

    init(model: SettingsModel, router: Router) {
        self.model = model
        self.router = router
        // TODO: make proper qr image
        self.qrCode = UIImage(
            cgImage: EFQRCode.generate(
                for: model.address,
                backgroundColor: CGColor.init(gray: 0, alpha: 0)
            )!
        )
        self.address = model.address

        self.model.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case let .error(error):
                    self?.router.play(event: .error(error))
                case let .update(balance):
                    self?.balance = balance
                case let .priceInfo(currentPrice, lastPriceUpdateInfo):
                    self?.currentPrice = currentPrice
                    self?.lastPriceUpdateInfo = lastPriceUpdateInfo
                }
            }
            .store(in: &cancellables)

        model.refresh()
    }

    func didTapCopy() {
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

extension SettingsViewModel {
    var solarPayURL: URL {
        .init(string: "https://pay.solarlabs.ee/topup?currency=dvpn&wallet=\(address)")!
    }
}
