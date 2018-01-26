//
//  ExchangeKeychainServiceProvider.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeKeychainServiceProvider: KeychainServiceProtocol {

    func save(identifier: String, value: [String : Any]) throws {
        log.debug("Set key: \(identifier)\nvalue: \(value))")
        try KeychainWrapper.setDictionary(value, for: identifier)
    }
    
    func save(account: String, key: String, value: String) {
        log.debug("Set account: \(account)\nkey: \(key)\nvalue: \(value))")
        keychain[account, key] = value
    }
    
    func fetch(account: String, key: String) -> String? {
        return keychain[account, key]
    }
    
}
