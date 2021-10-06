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

    init(
        storage: GeneralSettingsStorage,
        securityService: SecurityService,
        walletService: WalletService,
        sentinelService: SentinelService,
        tunnelManager: TunnelManagerType,
        networkService: NetworkServiceType
    ) {
        self.storage = storage
        self.securityService = securityService
        self.walletService = walletService
        self.sentinelService = sentinelService
        self.tunnelManager = tunnelManager
        self.networkService = networkService
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

typealias CommonContextProtocol = NoContext
    & HasStorage
    & HasWalletService
    & HasSentinelService
    & HasTunnelManager
    & HasNetworkService
