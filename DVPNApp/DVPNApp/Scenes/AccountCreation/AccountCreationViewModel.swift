//
//  AccountCreationViewModel.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 04.10.2021.
//

#if os(iOS)
import UIKit
#endif
import Combine
import HDWallet

final class AccountCreationViewModel: ObservableObject {
    typealias Router = AnyRouter<Route>
    private let router: Router

    enum Route {
        case error(Error)
        case privacy
        case openNodes
        case title(String)
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

    func didTapPaste() {
#if os(iOS)
        UIImpactFeedbackGenerator.lightFeedback()
#endif
        UIPasteboard.general.string?.splitToArray(separator: " ").prefix(24).enumerated().forEach { index, value in
            mnemonic[index] = value
        }

        model.check(mnemonic: mnemonic)
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
