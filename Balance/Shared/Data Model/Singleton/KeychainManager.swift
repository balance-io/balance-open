//
//  KeychainManager.swift
//  Bal
//
//  Created by Jamie Rumbelow on 30/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class KeychainManagerFactory {
    static var instances: [String: KeychainManagement] = [:]
    
    func instanceForAccount(_ account: String) -> KeychainManagement {
        var manager = KeychainManagerFactory.instances[account]
        if manager == nil {
            manager = KeychainManager(keychainName: account)
            KeychainManagerFactory.instances[account] = manager
        }
        return manager!
    }
    
    subscript(account: String) -> KeychainManagement {
        return instanceForAccount(account)
    }
    
    subscript(account: String, key: String) -> String? {
        get {
            let manager = instanceForAccount(account)
            return manager[key]
        }
        set {
            var manager = instanceForAccount(account)
            manager[key] = newValue
        }
    }
}

class KeychainManager: KeychainManagement {
    let keychainName: String
    
    var empty: Bool {
        do {
            return try KeychainWrapper.getDictionary(forIdentifier: keychainName) == nil
        } catch {
            log.severe("Couldn't read from keychain: \(error)")
        }
        return true
    }
    
    required init(keychainName: String) {
        self.keychainName = keychainName
    }
    
    subscript (key: String) -> String? {
        get {
            do {
                if let dict = try KeychainWrapper.getDictionary(forIdentifier: keychainName), let value = dict[key] as? String {
                    return value
                }
            } catch {
                log.severe("Couldn't read from keychain using key \(key): \(error)")
            }
            return nil
        }
        set {
            if let newValue = newValue {
                do {
                    if var dict = try KeychainWrapper.getDictionary(forIdentifier: keychainName) {
                        dict[key] = newValue
                        try KeychainWrapper.setDictionary(dict, forIdentifier: keychainName)
                    } else {
                        try KeychainWrapper.setDictionary([key: newValue], forIdentifier: keychainName)
                    }
                } catch {
                    log.severe("Couldn't write to keychain using key \(key): \(error)")
                }
            } else {
                // Nil value, so remove it from the dictionary
                do {
                    if var dict = try KeychainWrapper.getDictionary(forIdentifier: keychainName) {
                        dict.removeValue(forKey: key)
                        try KeychainWrapper.setDictionary(dict, forIdentifier: keychainName)
                    }
                } catch {
                    log.severe("Couldn't write to keychain using key \(key): \(error)")
                }
            }
        }
    }
    
    func clear() {
        do {
            try KeychainWrapper.deleteDictionary(forIdentifier: keychainName)
        } catch {
            log.severe("Couldn't delete from keychain: \(error)")
        }
    }
}
