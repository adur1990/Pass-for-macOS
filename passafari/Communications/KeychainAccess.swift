//
//  KeychainAccess.swift
//  passafari
//
//  Created by Artur Sterz on 05.12.18.
//  Copyright © 2018 Artur Sterz. All rights reserved.
//

import Foundation

let label = "Passafari"
let description = "Passphrase for GPG key used for Passafari"

let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                            kSecMatchLimit as String: kSecMatchLimitOne,
                            kSecReturnData as String: kCFBooleanTrue,
                            kSecAttrAccount as String: description
]

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

func storePassphrase(passphrase: String) throws {
    let passphraseData = passphrase.data(using: String.Encoding.utf8)!
    
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecValueData as String: passphraseData,
                                kSecAttrLabel as String: label,
                                kSecAttrAccount as String: description]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
}

func searchPassphrase() throws -> String {
    var item: AnyObject?
    let status = SecItemCopyMatching(searchQuery as CFDictionary, UnsafeMutablePointer(&item))
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    guard let passphraseData = item as? Data,
        let passphrase = String(data: passphraseData, encoding: .utf8)
        else {
            throw KeychainError.unexpectedPasswordData
    }

    return passphrase
}

func updatePassphrase(passphrase: String) throws {
    let passphraseData = passphrase.data(using: String.Encoding.utf8)!
    let attributes: [String: Any] = [kSecValueData as String: passphraseData]
    
    let status = SecItemUpdate(searchQuery as CFDictionary, attributes as CFDictionary)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
}

func deletePassphrase() throws {
    let status = SecItemDelete(searchQuery as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
}
