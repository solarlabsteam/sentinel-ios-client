//
//  ContextBuilder.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 05.08.2021.
//

import Foundation
import SentinelWallet

/// This class should configure all required services and inject them into a Context
final class ContextBuilder {
    func buildContext() -> CommonContext {
        let storage = GeneralSettingsStorage(settingsStorageStrategy: UserDefaultsStorageStrategy())
        let securityService = SecurityService()
        let walletService = buildWalletService(storage: storage, securityService: securityService)
        let tunnelManager = TunnelManager(storage: storage)
        let networkService = NetworkService()
        let userService = UserService(walletService: walletService)
        let preloadService = PreloadService(userService: userService)

        return CommonContext(
            storage: storage,
            securityService: securityService,
            walletService: walletService,
            sentinelService: .init(walletService: walletService),
            tunnelManager: tunnelManager,
            networkService: networkService,
            userService: userService,
            preloadService: preloadService
        )
    }

    func buildWalletService(
        storage: GeneralSettingsStorage,
        securityService: SecurityService
    ) -> WalletService {
        guard let walletAddress = storage.walletAddress(), !walletAddress.isEmpty else {
            switch WalletManager(securityService: securityService).generateWallet() {
            case .failure(let error):
                fatalError("failed to generate wallet due to \(error), terminate")
            case .success(let walletService):
                storage.set(wallet: walletService.accountAddress)
                return walletService
            }
        }
        return WalletService(for: walletAddress, securityService: securityService)
    }

    func buildTunnelsManager(completion: @escaping (TunnelsService) -> Void) {
        TunnelsService.create { result in
            switch result {
            case .failure(let error):
                fatalError("failed to create a manager due to \(error), terminate")

            case .success(let tunnelsManager):
                completion(tunnelsManager)
            }
        }
    }
}
