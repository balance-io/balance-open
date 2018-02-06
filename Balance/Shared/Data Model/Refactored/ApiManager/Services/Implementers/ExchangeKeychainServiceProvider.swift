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
        guard let keychainAccounts = buildKeychainAccounts(for: source, with: identifier) else {
            log.debug("Error - Keychain accounts can't be created for saving credentials on keychain, source: \(source.description)")
            return
        }
        
        switch source {
        case .poloniex:
            save(account: keychainAccounts.secretKey, key: KeychainConstants.secretKey, value: credentials.secretKey)
            save(account: keychainAccounts.apiKey, key: KeychainConstants.apiKey, value: credentials.apiKey)
        case .coinbase:
            guard let credentials = credentials as? OAUTHCredentials else {
                log.debug("Error - Can't use credentials type to be saved on keychain")
                return
            }
            
            save(account: keychainAccounts.accessToken, key: KeychainConstants.accessToken, value: credentials.accessToken)
            save(account: keychainAccounts.refreshToken, key: KeychainConstants.refreshToken, value: credentials.refreshToken)
            CoinbasePreferences.apiScope = credentials.apiScope
            CoinbasePreferences.tokenExpireDate = credentials.expireDate
        case .kraken, .bitfinex, .gdax:
            save(account: keychainAccounts.commonKey, key: KeychainConstants.secretKey, value: credentials.secretKey)
            save(account: keychainAccounts.commonKey, key: KeychainConstants.apiKey, value: credentials.apiKey)
            
            if !credentials.passphrase.isEmpty {
                save(account: keychainAccounts.commonKey, key: KeychainConstants.passphrase, value: credentials.passphrase)
            }
        case .ethplorer, .blockchain:
            save(account: keychainAccounts.addressKey, key: KeychainConstants.address, value: credentials.address)
        default:
            return
        }
    }
    
    func fetch(account: String, key: String) -> String? {
        return keychain[account, key]
    }
    
    func fetchCredentials(with identifer: String, source: Source, name: String?) -> Credentials? {
        guard let accountValues = buildKeychainAccounts(for: source, with: identifer) else {
            return nil
        }
        
        switch source {
        case .coinbase:
            guard let accessToken = fetch(account: accountValues.accessToken, key: KeychainConstants.accessToken),
                let refreshToken = fetch(account: accountValues.refreshToken, key: KeychainConstants.refreshToken) else {
                    return nil
            }
            
            return CoinbaseAutentication(accessToken: accessToken, refreshToken: refreshToken)
        case .poloniex:
            guard let secretKey = fetch(account: accountValues.secretKey, key: KeychainConstants.secretKey),
                let apiKey = fetch(account: accountValues.apiKey, key: KeychainConstants.apiKey) else {
                    return nil
            }
            
            return BalanceCredentials(apiKey: apiKey, secretKey: secretKey)
        case .kraken, .gdax, .bitfinex:
            guard let secretKey = fetch(account: accountValues.commonKey, key: KeychainConstants.secretKey),
                let apiKey = fetch(account: accountValues.commonKey, key: KeychainConstants.apiKey) else {
                    return nil
            }
            
            let passphrase = fetch(account: accountValues.commonKey, key: KeychainConstants.passphrase) ?? ""
            
            return BalanceCredentials(apiKey: apiKey, secretKey: secretKey, passphrase: passphrase)
        case .ethplorer, .blockchain:
            guard let address = fetch(account: accountValues.addressKey, key: KeychainConstants.address) else {
                return nil
            }
            
            return BalanceCredentials(address: address, name: name ?? "")
        default:
            return nil
        }
    }
    
}

private struct KeychainAccountValues {
    let apiKey: String
    let secretKey: String
    let accessToken: String
    let refreshToken: String
    let commonKey: String
    let addressKey: String
    
    init(apiKey: String = "",
         secretKey: String = "",
         accessToken: String = "",
         refreshToken: String = "",
         commonKey: String = "",
         addressKey: String = ""
        )
    {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.commonKey = commonKey
        self.addressKey = addressKey
    }
}

private extension ExchangeKeychainServiceProvider {
    struct KeychainConstants {
        static let secretKey = "secret"
        static let apiKey = "apiKey"
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let passphrase = "passphrase"
        static let address = "address"
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
             // TODO: the old way uses for secretKeyAccount value the apiKeyAccount, it must use secretKeyAccount
//            let keychainSecretKeyAccount = "secret institutionId: \(identifier)"
            let keychainApiKeyAccount = "apiKey institutionId: \(identifier)"
            return KeychainAccountValues(apiKey: keychainApiKeyAccount, secretKey: keychainApiKeyAccount)
        case .coinbase:
            let keychainAccessTokenKey = "institutionId: \(identifier)"
            let keychainRefreshTokenKey = "refreshToken institutionId: \(identifier)"
            
            return KeychainAccountValues(accessToken: keychainAccessTokenKey, refreshToken: keychainRefreshTokenKey)
        case .kraken, .bitfinex, .gdax:
            let realIdentifer = computeIdentifier(for: source, with: identifier)
            
            return KeychainAccountValues(commonKey: realIdentifer)
        case .ethplorer, .blockchain:
            return KeychainAccountValues(addressKey: "address institutionId: \(identifier)")
        default:
            return nil
        }
    }
    
    func computeIdentifier(for source: Source, with identifier: String) -> String {
        switch source {
        case .gdax:
            return "com.GDAXAPIClient.Credentials.\(identifier)"
        case .kraken:
            return "com.KrakenAPIClient.Credentials.\(identifier)"
        case .bitfinex:
            return "com.BitfinexAPIClient.Credentials.\(identifier)"
        default:
            return identifier
        }
    }
    
}
