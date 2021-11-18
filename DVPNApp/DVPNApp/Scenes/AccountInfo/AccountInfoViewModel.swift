//
//  AccountInfoViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 23.08.2021.
//

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

import Foundation
import FlagKit
import SentinelWallet
import Combine
import EFQRCode

final class AccountInfoViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router
    
    enum Route {
        case error(Error)
        case info(String)
    }
    
    @Published private(set) var qrCode: ImageAsset.Image
    @Published private(set) var address: String
    @Published private(set) var balance: String?
    @Published private(set) var currentPrice: String?
    @Published private(set) var lastPriceUpdateInfo: String?
    @Published private(set) var priceArrowImage: ImageAsset.Image = .init()
    
    private let model: AccountInfoModel
    private var cancellables = Set<AnyCancellable>()
    
    init(model: AccountInfoModel, router: Router) {
        self.model = model
        self.router = router
        
        // swiftlint:disable force_unwrapping
        
#if os(iOS)
        self.qrCode = UIImage(
            cgImage: EFQRCode.generate(
                for: model.address,
                   backgroundColor: CGColor.init(gray: 0, alpha: 0)
            )!
        )
#elseif os(macOS)
        
        let code = EFQRCode.generate(
            for: model.address,
               backgroundColor: CGColor.init(gray: 0, alpha: 0)
        )!
        
        self.qrCode = NSImage(cgImage: code, size: .init(width: 150, height: 150))
#endif
        
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
                case let .set(exchangeRates):
                    self?.setPriceInfo(exchangeRates)
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
        
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        
#if os(iOS)
        UIPasteboard.general.string = model.address
#elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(model.address, forType: .string)
 #endif
    }
    
    func didTapShare() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        
#if os(iOS)
        let activityVC = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?
            .present(activityVC, animated: true, completion: nil)
#endif
#warning("Make share button work in macOS")
    }
}

extension AccountInfoViewModel {
    private func setPriceInfo(_ exchangeRates: [ExchangeRates]) {
        let exchangeRate = exchangeRates.first
        
        guard let exchangeRate = exchangeRate, let priceInfo = exchangeRate.prices.first else {
            log.error("Loaded price is nil")
            return
        }
        
        let denom = priceInfo.currency == "usd" ? "$" : "?"
        
        let roundedPriceString = String(priceInfo.currentPrice.roundToDecimal(3))
        
        let roundedPercent = priceInfo.dailyPriceChangePercentage.roundToDecimal(2)
        
        let roundedPercentString = String(roundedPercent)
        
        currentPrice = "\(denom) \(roundedPriceString)"
        lastPriceUpdateInfo = "\(roundedPercentString)% (24h)"
        
        priceArrowImage = roundedPercent >= 0 ? Asset.Icons.upArrow.image
            : Asset.Icons.downArrow.image
    }
}
