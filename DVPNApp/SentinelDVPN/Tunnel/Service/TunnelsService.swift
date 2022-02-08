//
//  TunnelsService.swift
//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 16.06.2021.
//

import Foundation
import WireGuardKit
import NetworkExtension

final public class TunnelsService {

    private(set) var tunnels: [TunnelContainer]
    weak var statusDelegate: TunnelsServiceStatusDelegate?

    private var statusObservationToken: NotificationToken?
    private var awaitingObservationToken: NSKeyValueObservation?
    private var configurationsObservationToken: NotificationToken?

    init(tunnelProviders: [NETunnelProviderManager]) {
        tunnels = tunnelProviders
            .map { TunnelContainer(tunnel: $0) }
            .sorted { TunnelsService.nameIsLess(lhs: $0.name, than: $1.name) }
        startObservingTunnelStatuses()
        startObservingTunnelConfigurations()
    }

    static func nameIsLess(lhs: String, than rhs: String) -> Bool {
        lhs.compare(
            rhs,
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive, .numeric]
        ) == .orderedAscending
    }

    func startObservingTunnelConfigurations() {
        configurationsObservationToken = NotificationCenter.default.observe(
            name: .NEVPNConfigurationChange,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                // We schedule reload() in a subsequent runloop to ensure
                // that the completion handler of loadAllFromPreferences
                // is called after the completion handler of the saveToPreferences or removeFromPreferences call,
                // if any, that caused this notification to fire. This notification can also fire
                // as a result of a tunnel getting added or removed outside of the app.
                self?.reload()
            }
        }
    }

    static func create(completionHandler: @escaping (Result<TunnelsService, TunnelsServiceError>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                log.error("Failed to load tunnel provider managers: \(error)")
                completionHandler(.failure(TunnelsServiceError.loadTunnelsFailed(systemError: error)))
                return
            }

            var tunnelManagers = managers ?? []
            var references: Set<Data> = []
            var tunnelNames: Set<String> = []

            for (index, tunnelManager) in tunnelManagers.enumerated().reversed() {
                if let tunnelName = tunnelManager.localizedDescription {
                    tunnelNames.insert(tunnelName)
                }
                guard let provider = tunnelManager.provider else { continue }

                if provider.migrateConfigurationIfNeeded(with: tunnelManager.localizedDescription ?? "unknown") {
                    tunnelManager.saveToPreferences { _ in }
                }
                
                let passwordRef: Data?
                if provider.providerConfiguration?["UID"] as? uid_t == getuid() {
                    passwordRef = provider.verifyConfigurationReference() ? provider.passwordReference : nil
                } else {
                    passwordRef = provider.passwordReference // To handle multiple users in macOS, we skip verifying
                }
                
                if let data = passwordRef {
                    references.insert(data)
                } else {
                    log.info(
                        """
                        Removing orphaned tunnel
                        with non-verifying keychain entry: \(tunnelManager.localizedDescription ?? "<unknown>")
                        """
                        )
                    tunnelManager.removeFromPreferences { _ in }
                    tunnelManagers.remove(at: index)
                }
            }
            Keychain.deleteReferences(except: references)
            completionHandler(.success(TunnelsService(tunnelProviders: tunnelManagers)))
        }
    }

    func add(
        tunnelConfiguration: TunnelConfiguration,
        completionHandler: @escaping (Result<TunnelContainer, TunnelsServiceError>) -> Void
    ) {
        guard let name = tunnelConfiguration.name, !name.isEmpty else {
            completionHandler(.failure(TunnelsServiceError.emptyName))
            return
        }

        guard !tunnels.contains(where: { $0.name == name }) else {
            completionHandler(.failure(TunnelsServiceError.nameAlreadyExists))
            return
        }

        let tunnelProviderManager = NETunnelProviderManager()
        tunnelProviderManager.set(tunnelConfiguration: tunnelConfiguration)
        tunnelProviderManager.isEnabled = true

        let rule = NEOnDemandRuleConnect()
        rule.interfaceTypeMatch = .any

        tunnelProviderManager.onDemandRules = [rule]
        tunnelProviderManager.isOnDemandEnabled = true

        tunnelProviderManager.saveToPreferences { [weak self] error in
            if let error = error {
                log.error( "Add: Saving configuration failed: \(error)")
                tunnelProviderManager.provider?.destroyConfigurationReference()
                completionHandler(.failure(TunnelsServiceError.addTunnelFailed(systemError: error)))
                return
            }

            guard let self = self else { return }

            let tunnel = TunnelContainer(tunnel: tunnelProviderManager)
            self.tunnels.append(tunnel)
            self.tunnels.sort { TunnelsService.nameIsLess(lhs: $0.name, than: $1.name) }
            completionHandler(.success(tunnel))
        }
    }

    func set(
        onDemandEnabled: Bool,
        for tunnel: TunnelContainer,
        completion: @escaping (Result<TunnelContainer, TunnelsServiceError>) -> Void
    ) {
        let tunnelProviderManager = tunnel.tunnelProvider
        tunnelProviderManager.isOnDemandEnabled = onDemandEnabled
        tunnelProviderManager.isEnabled = true
        tunnelProviderManager.saveToPreferences { error in
            if let error = error {
                log.error("Modify: Saving configuration failed: \(error)")
                completion(.failure(TunnelsServiceError.addTunnelFailed(systemError: error)))
                return
            }

            tunnelProviderManager.loadFromPreferences { error in
                tunnel.isActivateOnDemandEnabled = tunnelProviderManager.isOnDemandEnabled
                if let error = error {
                    log.error("Modify: Re-loading after saving configuration failed: \(error)")
                    completion(.failure(TunnelsServiceError.loadTunnelsFailed(systemError: error)))
                    return
                }
                completion(.success(tunnel))
            }
        }
    }

    func modify(
        tunnel: TunnelContainer,
        tunnelConfiguration: TunnelConfiguration,
        completion: @escaping (Result<TunnelContainer, TunnelsServiceError>) -> Void
    ) {
        guard let name = tunnelConfiguration.name, !name.isEmpty else {
            completion(.failure(TunnelsServiceError.emptyName))
            return
        }

        let tunnelProviderManager = tunnel.tunnelProvider
        tunnelProviderManager.isOnDemandEnabled = true
        tunnelProviderManager.isEnabled = true
        let oldName = tunnelProviderManager.localizedDescription ?? ""
        let isNameChanged = name != oldName
        if isNameChanged {
            guard !tunnels.contains(where: { $0.name == name }) else {
                completion(.failure(TunnelsServiceError.nameAlreadyExists))
                return
            }
            tunnel.name = name
        }

        let isTunnelConfigurationChanged = tunnelProviderManager.tunnelConfiguration != tunnelConfiguration
        if isTunnelConfigurationChanged {
            tunnelProviderManager.set(tunnelConfiguration: tunnelConfiguration)
        }
        tunnelProviderManager.isEnabled = true
        tunnelProviderManager.saveToPreferences { [weak self] error in
            if let error = error {
                log.error("Modify: Saving configuration failed: \(error)")
                completion(.failure(TunnelsServiceError.addTunnelFailed(systemError: error)))
                return
            }

            guard let self = self else { return }
            if isNameChanged {
                self.tunnels.sort { TunnelsService.nameIsLess(lhs: $0.name, than: $1.name) }
            }

            if isTunnelConfigurationChanged {
                if tunnel.status == .connected || tunnel.status == .connecting || tunnel.status == .reasserting {
                    // Turn off the tunnel, and then turn it back on, so the changes are made effective
                    tunnel.status = .restarting
                    (tunnel.tunnelProvider.connection as? NETunnelProviderSession)?.stopTunnel()
                }
            }

            tunnelProviderManager.loadFromPreferences { error in
                tunnel.isActivateOnDemandEnabled = tunnelProviderManager.isOnDemandEnabled
                if let error = error {
                    log.error("Modify: Re-loading after saving configuration failed: \(error)")
                    completion(.failure(TunnelsServiceError.loadTunnelsFailed(systemError: error)))
                    return
                }
                completion(.success(tunnel))
            }
        }
    }

    func startActivation(of tunnel: TunnelContainer) {
        guard tunnels.contains(tunnel) else { return }

        guard tunnel.status == .disconnected else {
            statusDelegate?.activationAttemptFailed(for: tunnel, with: .inactive)
            return
        }

        if let alreadyWaitingTunnel = tunnels.first(where: { $0.status == .waiting }) {
            alreadyWaitingTunnel.status = .disconnected
        }

        if let tunnelInOperation = tunnels.first(where: { $0.status != .disconnected }) {
            log.info("Tunnel '\(tunnel.name)' waiting for deactivation of '\(tunnelInOperation.name)'")
            tunnel.status = .waiting
            activateAwaiting(tunnel: tunnelInOperation)
            if tunnelInOperation.status != .disconnecting {
                startDeactivation(of: tunnelInOperation)
            }
            return
        }

        tunnel.startActivation(statusDelegate: statusDelegate)
    }

    func startActivationOfLastTunnel() {
        guard let tunnel = tunnels.last else { return }
        startActivation(of: tunnel)
    }

    @discardableResult
    func startDeactivationOfActiveTunnel() -> Bool {
        guard let tunnel = tunnels.last, tunnel.status != .disconnected else { return false }
        set(onDemandEnabled: false, for: tunnel) { [weak self] _ in
            self?.startDeactivation(of: tunnel)
        }
        return true
    }

    func startDeactivation(of tunnel: TunnelContainer) {
        tunnel.isAttemptingActivation = false
        guard tunnel.status != .disconnected && tunnel.status != .disconnecting else { return }
        tunnel.startDeactivation(statusDelegate: statusDelegate)
    }

    func refreshStatuses() {
        tunnels.forEach { $0.refreshStatus() }
    }
}

// MARK: Private

private extension TunnelsService {
    func activateAwaiting(tunnel: TunnelContainer) {
        awaitingObservationToken = tunnel.observe(\.status) { [weak self] tunnel, _ in
            guard let self = self else { return }

            if tunnel.status == .disconnected {
                self.tunnels.first(where: { $0.status == .waiting })?
                    .startActivation(statusDelegate: self.statusDelegate)
                self.awaitingObservationToken = nil
            }
        }
    }

    func startObservingTunnelStatuses() {
        statusObservationToken = NotificationCenter.default.observe(
            name: .NEVPNStatusDidChange,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self] statusChangeNotification in
            guard let self = self,
                let session = statusChangeNotification.object as? NETunnelProviderSession,
                let tunnelProvider = session.manager as? NETunnelProviderManager,
                let tunnel = self.tunnels.first(where: { $0.tunnelProvider == tunnelProvider })
            else { return }
            
            let description = tunnel.tunnelProvider.connection.status.description
            log.debug("Tunnel '\(tunnel.name)' status changed to '\(description)'")

            if tunnel.isAttemptingActivation {
                switch session.status {
                case .disconnected:
                    tunnel.isAttemptingActivation = false
                    self.statusDelegate?.activationFailed(
                        for: tunnel,
                        with: .activationAttemptFailed(wasOnDemandEnabled: tunnelProvider.isOnDemandEnabled)
                    )
                case .connected:
                    tunnel.isAttemptingActivation = false
                    self.statusDelegate?.activationSucceeded(for: tunnel)
                default:
                    tunnel.refreshStatus()
                }
            }

            if session.status == .invalid {
                tunnel.isAttemptingActivation = false
                self.statusDelegate?.deactivationSucceeded(for: tunnel)
            }

            guard tunnel.status == .restarting else {
                tunnel.refreshStatus()
                return
            }

            switch session.status {
            case .disconnected:
                tunnel.startActivation(statusDelegate: self.statusDelegate)
            case .connected:
                tunnel.status = .connected
                self.statusDelegate?.activationSucceeded(for: tunnel)
            default:
                return
            }
        }
    }

    func reload() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, _ in
            guard let self = self else { return }
            let loadedTunnelProviders = managers ?? []

            self.tunnels.enumerated().reversed().forEach { index, currentTunnel in
                if !loadedTunnelProviders.contains(where: { $0.isEquivalent(to: currentTunnel) }) {
                    // Tunnel was deleted outside the app
                    self.tunnels.remove(at: index)
                }
            }

            loadedTunnelProviders.forEach { loadedTunnelProvider in
                if let matchingTunnel = self.tunnels.first(where: { loadedTunnelProvider.isEquivalent(to: $0) }) {
                    matchingTunnel.tunnelProvider = loadedTunnelProvider
                    matchingTunnel.refreshStatus()
                } else {
                    // Tunnel was added outside the app
                    if let configuration = loadedTunnelProvider.provider {
                        if configuration.migrateConfigurationIfNeeded(
                            with: loadedTunnelProvider.localizedDescription ?? "unknown"
                        ) {
                            loadedTunnelProvider.saveToPreferences { _ in }
                        }
                    }
                    let tunnel = TunnelContainer(tunnel: loadedTunnelProvider)
                    self.tunnels.append(tunnel)
                    self.tunnels.sort { TunnelsService.nameIsLess(lhs: $0.name, than: $1.name) }
                }
            }
        }
    }
}
