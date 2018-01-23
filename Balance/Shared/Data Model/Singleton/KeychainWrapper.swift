//
//  Keychain.swift
//  BalancemacOS
//
//  Created by Benjamin Baron on 11/30/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//
// NOTE: This is a drop in replacement for the Locksmith keychain wrapper library.
//       This is meant to allow for reading value stored by Locksmith for a smooth
//       transition, which is why it's implemented in this particular way.

import Foundation
import Security

struct KeychainWrapper {
    static func serviceIdentifier() throws -> String {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw "Bundle identifier was nil"
        }
        
        let serviceIdentifier = bundleIdentifier + defaults.uniqueKeychainString
        return serviceIdentifier
    }
    
    static func errorMessage(status: OSStatus) -> String {
        #if os(OSX)
            if let message = SecCopyErrorMessageString(status, nil) {
                return message as String
            }
            return "Unknown status code"
        #else
            let nsError = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            return nsError.localizedDescription
        #endif
    }
    
    static func setDictionary(_ dictionary: [String: Any], forIdentifier identifier: String) throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        var keychainQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                              kSecAttrService: try serviceIdentifier(),
                                              kSecAttrAccount: identifier,
                                              kSecValueData: data]
        #if os(iOS)
            // Ensure background refresh works
            keychainQuery[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
        #endif
        
        let deleteStatus = SecItemDelete(keychainQuery as CFDictionary)
        let addStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if addStatus != errSecSuccess {
            throw "deleteStatus: \(deleteStatus) - \(errorMessage(status: deleteStatus)) addStatus: \(addStatus) - \(errorMessage(status: addStatus))"
        }
    }
    
    static func getDictionary(forIdentifier identifier: String) throws -> [String: Any]? {
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: try serviceIdentifier(),
                             kSecAttrAccount: identifier,
                             kSecReturnData: kCFBooleanTrue,
                             kSecMatchLimit: kSecMatchLimitOne] as CFDictionary
        
        var data: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &data)
        
        if status == errSecSuccess, let data = data as? Data, let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] {
            return dict
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw "\(status) - \(errorMessage(status: status))"
        }
    }
    
    static func deleteDictionary(forIdentifier identifier: String) throws {
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: try serviceIdentifier(),
                             kSecAttrAccount: identifier]  as CFDictionary
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        if status != errSecSuccess {
            throw "\(status) - \(errorMessage(status: status))"
        }
    }
    
    static func resetKeychain() throws {
        try deleteAllKeysForSecClass(kSecClassGenericPassword)
        try deleteAllKeysForSecClass(kSecClassInternetPassword)
        try deleteAllKeysForSecClass(kSecClassCertificate)
        try deleteAllKeysForSecClass(kSecClassKey)
        try deleteAllKeysForSecClass(kSecClassIdentity)
    }
    
    static func deleteAllKeysForSecClass(_ secClass: CFString) throws {
        let dict: [NSString : Any] = [kSecClass : secClass]
        let status = SecItemDelete(dict as CFDictionary)
        if status != errSecSuccess {
            throw "Error deleting all items for security class \(secClass): \(status) - \(errorMessage(status: status))"
        }
    }
}
