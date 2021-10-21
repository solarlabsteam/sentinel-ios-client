//
//  Context.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 05.08.2021.
//

import Foundation
import SentinelWallet

protocol NoContext {}

final class CommonContext {
    let storage: GeneralSettingsStorage
    private(set) var walletService: WalletService
    private(set) var sentinelService: SentinelService
    let securityService: SecurityService
    let tunnelManager: TunnelManagerType
    let networkService: NetworkServiceType
    let userService: UserService
    let preloadService: PreloadServiceType

    init(
        storage: GeneralSettingsStorage,
        securityService: SecurityService,
        walletService: WalletService,
        sentinelService: SentinelService,
        tunnelManager: TunnelManagerType,
        networkService: NetworkServiceType,
        userService: UserService,
        preloadService: PreloadServiceType
    ) {
        self.storage = storage
        self.securityService = securityService
        self.walletService = walletService
        self.sentinelService = sentinelService
        self.tunnelManager = tunnelManager
        self.networkService = networkService
        self.userService = userService
        self.preloadService = preloadService
    }

    func resetWalletContext() {
        guard let walletAddress = storage.walletAddress(), !walletAddress.isEmpty else {
           return
        }
        walletService = WalletService(for: walletAddress, securityService: securityService)
        sentinelService = SentinelService(walletService: walletService)
    }
}

extension CommonContext: NoContext {}

protocol HasStorage { var storage: GeneralSettingsStorage { get } }
extension CommonContext: HasStorage {}

protocol HasWalletService { var walletService: WalletService { get } }
extension CommonContext: HasWalletService {}

protocol HasSentinelService { var sentinelService: SentinelService { get } }
extension CommonContext: HasSentinelService {}

protocol HasSecurityService { var securityService: SecurityService { get } }
extension CommonContext: HasSecurityService {}

protocol HasTunnelManager { var tunnelManager: TunnelManagerType { get } }
extension CommonContext: HasTunnelManager {}

protocol HasNetworkService { var networkService: NetworkServiceType { get } }
extension CommonContext: HasNetworkService {}

protocol HasUserService { var userService: UserService { get } }
extension CommonContext: HasUserService {}

protocol HasPreloadService { var preloadService: PreloadServiceType { get } }
extension CommonContext: HasPreloadService {}

typealias CommonContextProtocol = NoContext
    & HasStorage
    & HasWalletService
    & HasSentinelService
    & HasTunnelManager
    & HasNetworkService
