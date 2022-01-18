//
//  SecurityService.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 12.11.2021.
//

import Foundation
import SentinelWallet
import HDWallet

private struct Constants {
    let mnemonicsCount = 24
    let serviceName = "SecurityService"
}
private let constants = Constants()

final public class SecurityService: SecurityServiceType {
    public func save(mnemonics: [String], for account: String) -> Bool {
        let mnemonicString = mnemonics.joined(separator: " ") as AnyObject
        let accountAttr = account.sha1() as AnyObject

        let query: [String: AnyObject] = [
            kSecAttrService as String: constants.serviceName as AnyObject,
            kSecAttrAccount as String: accountAttr,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: mnemonicString
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            return mnemonicsExists(for: account)
        }

        return status == errSecSuccess
    }

    public func loadMnemonics(for account: String) -> [String]? {
        let query: [String: AnyObject] = [
            kSecAttrService as String: constants.serviceName as AnyObject,
            kSecAttrAccount as String: account.sha1() as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

        guard status != errSecItemNotFound else {
            log.error(status)
            return nil
        }

        guard status == errSecSuccess, let keychainData = itemCopy as? Data else {
            log.error(status)
            return nil
        }

        guard let mnemonicString = String(data: keychainData, encoding: String.Encoding.utf8) as String? else {
            return nil
        }

        return mnemonicString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
    }

    public func mnemonicsExists(for account: String) -> Bool {
        loadMnemonics(for: account) != nil
    }

    public func restore(from mnemonics: [String]) -> Result<String, Error> {
        guard !mnemonics.isEmpty else {
            return .failure(SecurityServiceError.emptyInput)
        }

        guard
            mnemonics.count == constants.mnemonicsCount, mnemonics.allSatisfy({ WordList.english.words.contains($0) })
        else {
            return .failure(SecurityServiceError.invalidInput)
        }

        guard let restoredAddress = restoreAddress(for: mnemonics) else {
            return .failure(SecurityServiceError.invalidInput)
        }

        return .success(restoredAddress)
    }
}
