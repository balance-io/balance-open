//
//  KeychainManager.swift
//  Bal
//
//  Created by Jamie Rumbelow on 30/08/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith

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
        return Locksmith.loadDataForUserAccount(userAccount: keychainName) == nil
    }
    
    required init(keychainName: String) {
        self.keychainName = keychainName
    }
    
    subscript (key: String) -> String? {
        get {
            if let dict = Locksmith.loadDataForUserAccount(userAccount: keychainName), let value = dict[key] as? String {
                return value
            }
            return nil
        }
        set {
            if let newValue = newValue {
                do {
                    if var dict = Locksmith.loadDataForUserAccount(userAccount: keychainName) {
                        dict[key] = newValue
                        try Locksmith.updateData(data: dict, forUserAccount: keychainName)
                    } else {
                        try Locksmith.updateData(data: [key: newValue], forUserAccount: keychainName)
                    }
                } catch {
                    log.severe("Couldn't write to keychain: \(error)")
                }
            } else {
                // Nil value, so remove it from the dictionary
                if var dict = Locksmith.loadDataForUserAccount(userAccount: keychainName) {
                    dict.removeValue(forKey: key)
                    do {
                        try Locksmith.updateData(data: dict, forUserAccount: keychainName)
                    } catch {
                        log.severe("Couldn't write to keychain: \(error)")
                    }
                }
            }
        }
    }
    
    func clear() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: keychainName)
        } catch {
            log.severe("Couldn't delete from keychain: \(error)")
        }
    }
}
