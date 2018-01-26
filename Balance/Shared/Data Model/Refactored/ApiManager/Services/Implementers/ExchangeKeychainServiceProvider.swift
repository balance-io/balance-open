//
//  ExchangeKeychainServiceProvider.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeKeychainServiceProvider: KeychainServiceProtocol {

    func save(source: Source, identifier: String, credentials: Credentials) {
        switch source {
        case .poloniex:
            let keychainSecretKeyAccount = "secret institutionId: \(identifier)"
            save(account: keychainSecretKeyAccount, key: KeychainConstants.secretKey, value: credentials.secretKey)
            let keychainApiKeyAccount = "apiKey institutionId: \(identifier)"
            save(account: keychainApiKeyAccount, key: KeychainConstants.secretKey, value: credentials.apiKey)
        default:
            return
        }
    }
    
    func fetch(account: String, key: String) -> String? {
        return keychain[account, key]
    }
    
}


private extension ExchangeKeychainServiceProvider {
    
    struct KeychainConstants {
        static let secretKey = "secret"
        static let apiKey = "apiKey"
    }
    
    func save(identifier: String, value: [String : Any]) throws {
        log.debug("Set key: \(identifier)\nvalue: \(value)) on keychain")
        try KeychainWrapper.setDictionary(value, for: identifier)
    }
    
    func save(account: String, key: String, value: String) {
        log.debug("Set account: \(account)\nkey: \(key)\nvalue: \(value)) on keychain")
        keychain[account, key] = value
    }
    
}
