//
//  ExchangeKeychainServiceProvider.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeKeychainServiceProvider: KeychainServiceProtocol {

    func save(source: Source, identifier: String, credentials: BaseCredentials) {
        switch source {
        case .poloniex:
            guard let credentials = credentials as? Credentials else {
                log.debug("Error - Can't use credentials type to be saved on keychain")
                return
            }
            
            let keychainSecretKeyAccount = "secret institutionId: \(identifier)"
            save(account: keychainSecretKeyAccount, key: KeychainConstants.secretKey, value: credentials.secretKey)
            let keychainApiKeyAccount = "apiKey institutionId: \(identifier)"
            save(account: keychainApiKeyAccount, key: KeychainConstants.secretKey, value: credentials.apiKey)
        case .coinbase:
            guard let credentials = credentials as? OAUTHCredentials else {
                log.debug("Error - Can't use credentials type to be saved on keychain")
                return
            }
            
            let keychainAccessTokenKey = "institutionId: \(identifier)"
            save(account: keychainAccessTokenKey, key: KeychainConstants.accessToken, value: credentials.accessToken)
            let keychainRefreshTokenKey = "refreshToken institutionId: \(identifier)"
            save(account: keychainRefreshTokenKey, key: KeychainConstants.refreshToken, value: credentials.refreshToken)
            CoinbasePreferences.apiScope = credentials.apiScope
            CoinbasePreferences.tokenExpireDate = Date().addingTimeInterval(credentials.expiresIn - 10.0)
        default:
            return
        }
    }
    
    func fetch(account: String, key: String) -> String? {
        return keychain[account, key]
    }
    
}

class CoinbasePreferences {
    
    private struct PreferencesKeys {
        static let tokenExpireDate = "tokenExpireDateKey"
        static let apiScope = "Institution.apiScopeKey"
    }
    
    static var tokenExpireDate: Date {
        get {
            return UserDefaults.standard.object(forKey: PreferencesKeys.tokenExpireDate) as? Date ?? Date.distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PreferencesKeys.tokenExpireDate)
        }
    }
    
    static var isTokenExpired: Bool {
        return Date().timeIntervalSince(tokenExpireDate) > 0.0
    }
    
    static var apiScope: String? {
        get {
            return UserDefaults.standard.string(forKey: PreferencesKeys.apiScope)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PreferencesKeys.apiScope)
        }
    }
    
}

private extension ExchangeKeychainServiceProvider {
    
    struct KeychainConstants {
        static let secretKey = "secret"
        static let apiKey = "apiKey"
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
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
