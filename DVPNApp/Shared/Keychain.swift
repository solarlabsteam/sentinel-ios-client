//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.06.2021.
//

import Foundation
import Security

final class Keychain {
    static var appGroupId: String? {
        return "group.co.sentinel.dvpn"
    }

    static func openReference(with data: Data) -> String? {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(
            [kSecClass: kSecClassGenericPassword,
             kSecValuePersistentRef: data,
             kSecReturnData: true
            ] as CFDictionary,
            &result
        )
        if status != errSecSuccess || result == nil {
            log.error("Unable to open config from keychain: \(status)")
            return nil
        }
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    static func makeReference(
        containing value: String,
        with name: String,
        previouslyReferencedBy oldReference: Data? = nil
    ) -> Data? {
        var status: OSStatus
        guard var bundleIdentifier = Bundle.main.bundleIdentifier else {
            log.error("Unable to determine bundle identifier")
            return nil
        }
        if bundleIdentifier.hasSuffix(".network-extension") {
            bundleIdentifier.removeLast(".network-extension".count)
        }
        let itemLabel = "DVPN Tunnel: \(name)"
        var items: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: itemLabel,
            kSecAttrAccount: name + ": " + UUID().uuidString,
            kSecAttrDescription: "wireGuardConfig",
            kSecAttrService: bundleIdentifier,
            kSecValueData: value.data(using: .utf8) as Any,
            kSecReturnPersistentRef: true
        ]
        
#if os(iOS)
        items[kSecAttrAccessGroup] = Keychain.appGroupId
        items[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
#elseif os(macOS)
        items[kSecAttrSynchronizable] = false
        items[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        
        guard let extensionPath = Bundle.main.builtInPlugInsURL?.appendingPathComponent("SentinelDVPNmacOSNetworkExtension.appex", isDirectory: true).path else {
            log.error("Unable to determine app extension path")
            return nil
        }
        var extensionApp: SecTrustedApplication?
        var mainApp: SecTrustedApplication?
        status = SecTrustedApplicationCreateFromPath(extensionPath, &extensionApp)
        if status != kOSReturnSuccess || extensionApp == nil {
            log.error("Unable to create keychain extension trusted application object: \(status)")
            return nil
        }
        status = SecTrustedApplicationCreateFromPath(nil, &mainApp)
        if status != errSecSuccess || mainApp == nil {
            log.error("Unable to create keychain local trusted application object: \(status)")
            return nil
        }
        var access: SecAccess?
        status = SecAccessCreate(itemLabel as CFString, [extensionApp!, mainApp!] as CFArray, &access)
        if status != errSecSuccess || access == nil {
            log.error("Unable to create keychain ACL object: \(status)")
            return nil
        }
        items[kSecAttrAccess] = access!
#endif

        var reference: CFTypeRef?
        status = SecItemAdd(items as CFDictionary, &reference)
        if status != errSecSuccess || reference == nil {
            log.error("Unable to add config to keychain: \(status)")
            return nil
        }
        if let oldReference = oldReference {
            deleteReference(with: oldReference)
        }
        return reference as? Data
    }

    static func deleteReference(with ref: Data) {
        let ret = SecItemDelete([kSecValuePersistentRef: ref] as CFDictionary)
        if ret != errSecSuccess {
            log.error("Unable to delete config from keychain: \(ret)")
        }
    }

    static func deleteReferences(except whitelist: Set<Data>) {
        var result: CFTypeRef?
        let ret = SecItemCopyMatching(
            [kSecClass: kSecClassGenericPassword,
             kSecAttrService: Bundle.main.bundleIdentifier as Any,
             kSecMatchLimit: kSecMatchLimitAll,
             kSecReturnPersistentRef: true] as CFDictionary,
            &result
        )
        guard ret == errSecSuccess || result != nil, let items = result as? [Data] else { return }

        items.filter { !whitelist.contains($0) }.forEach { deleteReference(with: $0) }
    }

    static func verifyReference(called ref: Data) -> Bool {
        return SecItemCopyMatching(
            [kSecClass: kSecClassGenericPassword, kSecValuePersistentRef: ref] as CFDictionary,
            nil
        ) != errSecItemNotFound
    }
}
