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
        guard let keychainAccounts = buildKeychainAccounts(for: source, with: identifier) else {
            log.debug("Error - Keychain accounts can't be created for saving credentials on keychain, source: \(source.description)")
            return
        }
        
        switch source {
        case .poloniex:
            guard let credentials = credentials as? Credentials else {
                log.debug("Error - Can't use credentials type to be saved on keychain")
                return
            }
            
            save(account: keychainAccounts.secretKey, key: KeychainConstants.secretKey, value: credentials.secretKey)
            save(account: keychainAccounts.apiKey, key: KeychainConstants.secretKey, value: credentials.apiKey)
        case .coinbase:
            guard let credentials = credentials as? OAUTHCredentials else {
                log.debug("Error - Can't use credentials type to be saved on keychain")
                return
            }
            
            save(account: keychainAccounts.accessToken, key: KeychainConstants.accessToken, value: credentials.accessToken)
            save(account: keychainAccounts.refreshToken, key: KeychainConstants.refreshToken, value: credentials.refreshToken)
            CoinbasePreferences.apiScope = credentials.apiScope
            CoinbasePreferences.tokenExpireDate = Date().addingTimeInterval(credentials.expiresIn - 10.0)
        default:
            return
        }
    }
    
    func fetch(account: String, key: String) -> String? {
        return keychain[account, key]
    }
    
    //TODO: NEED FINISH
    func fetchCredentials(for institution: Institution) -> BaseCredentials? {
        switch institution.source {
        case .coinbase:
            return nil
        default:
            return nil
        }
    }
    
}

//THIS SHOULD BE IMPROVED, ONLY SAVE THE LAST ACCOUNT REGISTER ON USER DEFAULT
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

private struct KeychainAccountValues {
    let apiKey: String
    let secretKey: String
    let accessToken: String
    let refreshToken: String
    
    init(apiKey: String = "", secretKey: String = "", accessToken: String = "", refreshToken: String = "") {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.accessToken = accessToken
        self.refreshToken = refreshToken
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
    
    func buildKeychainAccounts(for source: Source, with identifier: String) -> KeychainAccountValues? {
        switch source {
        case .poloniex:
            let keychainSecretKeyAccount = "secret institutionId: \(identifier)"
            let keychainApiKeyAccount = "apiKey institutionId: \(identifier)"
            
            return KeychainAccountValues(apiKey: keychainApiKeyAccount, secretKey: keychainSecretKeyAccount)
        case .coinbase:
            let keychainAccessTokenKey = "institutionId: \(identifier)"
            let keychainRefreshTokenKey = "refreshToken institutionId: \(identifier)"
            
            return KeychainAccountValues(accessToken: keychainAccessTokenKey, refreshToken: keychainRefreshTokenKey)
        default:
            return nil
        }
    }
    
}
