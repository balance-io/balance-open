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
    static func errorMessage(status: OSStatus) -> String {
        if let message = SecCopyErrorMessageString(status, nil) {
            return message as String
        }
        return "Unknown status code"
    }
    
    static func setDictionary(_ dictionary: [String: Any], forIdentifier identifier: String) throws {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw "Bundle identifier was nil"
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        var keychainQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                              kSecAttrService: bundleIdentifier,
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
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw "Bundle identifier was nil"
        }
        
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: bundleIdentifier,
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
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            throw "Bundle identifier was nil"
        }
        
        let keychainQuery = [kSecClass: kSecClassGenericPassword,
                             kSecAttrService: bundleIdentifier,
                             kSecAttrAccount: identifier]  as CFDictionary
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        if status != errSecSuccess {
            throw "\(status) - \(errorMessage(status: status))"
        }
    }
}
