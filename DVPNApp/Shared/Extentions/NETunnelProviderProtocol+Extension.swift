//  SentinelDVPN
//
//  Created by Lika Vorobyeva on 12.06.2021.
//

import NetworkExtension
import WireGuardKit

enum PacketTunnelProviderError: String, Error {
    case savedProtocolConfigurationIsInvalid
    case dnsResolutionFailure
    case couldNotStartBackend
    case couldNotDetermineFileDescriptor
    case couldNotSetNetworkSettings
}

extension NETunnelProviderProtocol {
    convenience init?(tunnelConfiguration: TunnelConfiguration, previouslyFrom old: NEVPNProtocol? = nil) {
        self.init()
        guard let name = tunnelConfiguration.name, let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }
        providerBundleIdentifier = bundleIdentifier + ".network-extension"

        passwordReference = Keychain.makeReference(
            containing: tunnelConfiguration.asWireGuardConfig(),
            with: name,
            previouslyReferencedBy: old?.passwordReference
        )
        guard passwordReference != nil else { return nil }
#if os(macOS)
        providerConfiguration = ["UID": getuid()]
#endif
        let endpoints = tunnelConfiguration.peers.compactMap { $0.endpoint }
        if endpoints.isEmpty {
            serverAddress = "Unspecified"
            return
        }
        if endpoints.count == 1 {
            serverAddress = endpoints[0].stringRepresentation
            return
        }
        serverAddress = "Multiple endpoints"
    }

    func asTunnelConfiguration(with name: String? = nil) -> TunnelConfiguration? {
        if let passwordReference = passwordReference, let config = Keychain.openReference(with: passwordReference) {
            return try? TunnelConfiguration(wireGuardConfig: config, with: name)
        }
        if let oldConfig = providerConfiguration?["WireGuardConfig"] as? String {
            return try? TunnelConfiguration(wireGuardConfig: oldConfig, with: name)
        }
        return nil
    }

    func destroyConfigurationReference() {
        guard let reference = passwordReference else { return }
        Keychain.deleteReference(with: reference)
    }

    func verifyConfigurationReference() -> Bool {
        guard let reference = passwordReference else { return false }
        return Keychain.verifyReference(called: reference)
    }

    @discardableResult
    func migrateConfigurationIfNeeded(with name: String) -> Bool {
        if let oldConfig = providerConfiguration?["WireGuardConfig"] as? String {
#if os(macOS)
            providerConfiguration = ["UID": getuid()]
#elseif os(iOS)
            providerConfiguration = nil
#endif
            guard passwordReference == nil else { return true }
            log.debug("Migrating tunnel configuration '\(name)'")
            passwordReference = Keychain.makeReference(containing: oldConfig, with: name)
            return true
        }
#if os(macOS)
        if passwordReference != nil && providerConfiguration?["UID"] == nil && verifyConfigurationReference() {
            providerConfiguration = ["UID": getuid()]
            return true
        }
#elseif os(iOS)
        if #available(iOS 15, *) {
            if passwordReference != nil && passwordReference!.count == 12 {
                var result: CFTypeRef?
                let ret = SecItemCopyMatching([kSecValuePersistentRef: passwordReference!,
                                              kSecReturnPersistentRef: true] as CFDictionary,
                                              &result)
                if ret != errSecSuccess || result == nil {
                    return false
                }
                guard let newReference = result as? Data else { return false }
                if !newReference.elementsEqual(passwordReference!) {
                    log.info("Migrating iOS 14-style keychain reference to iOS 15-style keychain reference for '\(name)'")
                    passwordReference = newReference
                    return true
                }
            }
        }
#endif
        return false
    }
}
