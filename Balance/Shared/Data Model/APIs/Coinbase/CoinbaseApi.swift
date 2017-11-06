//
//  CoinbaseApi.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Locksmith
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

typealias SuccessErrorBlock = (_ success: Bool, _ error: Error?) -> Void

fileprivate let connectionTimeout = 30.0
//fileprivate let subServerUrl = "http://localhost:8080/"
//fileprivate let subServerUrl = "https://bal-subscription-server-beta.appspot.com/"
//fileprivate let subServerUrl = "https://www.balancemysubscription.com/"
fileprivate let subServerUrl = "https://balance-server.appspot.com/"
fileprivate let clientId = "a6e15fbb0c3362b74360895f261fb079672c10eef79dcb72308c974408c5ce43"

// Save random state for current authentication request
fileprivate var lastState: String? = nil

struct CoinbaseApi: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (_ success: Bool, _ error: Error?, _ institution: Institution?) -> Void) {
        
    }

    @discardableResult static func authenticate() -> Bool {
        let redirectUri = "balancemymoney%3A%2F%2Fcoinbase"
        let responseType = "code"
        let scope = "wallet%3Auser%3Aread,wallet%3Aaccounts%3Aread,wallet%3Atransactions%3Aread"
        let state = String.random(32)
        let url = "https://www.coinbase.com/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&state=\(state)&response_type=\(responseType)&scope=\(scope)&account=all"
        
        do {
            #if os(OSX)
                _ = try NSWorkspace.shared.open(URL(string: url)!, options: [], configuration: [:])
            #else
                UIApplication.shared.open(URL(string: url)!)
            #endif
        } catch {
            // TODO: Better error handling
            log.error("Error opening Coinbase authentication URL: \(error)")
            return false
        }
        
        // Save random state for verification
        lastState = state
        return true
    }
    
    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock) {
        guard lastState == state else {
            DispatchQueue.main.async {
                completion(false, "state does not match saved state")
            }
            return
        }
        
        lastState = nil
        let urlString = "\(subServerUrl)coinbase/requestToken"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let parameters = "{\"code\":\"\(code)\"}"
        request.httpBody = parameters.data(using: .utf8)
        
        // TODO: Create enum types for each error
        let task = certValidatedSession.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw BalanceError.noData
                }
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject], let accessToken = JSONResult["accessToken"] as? String, accessToken.count > 0, let refreshToken = JSONResult["refreshToken"] as? String, refreshToken.count > 0, let expiresIn = JSONResult["expiresIn"] as? TimeInterval, let scope = JSONResult["scope"] as? String else {
                    throw BalanceError.jsonDecoding
                }
                
                // Create the institution and finish
                let institution = InstitutionRepository.si.institution(source: .coinbase, sourceInstitutionId: "", name: "Coinbase")
                institution?.accessToken = accessToken
                institution?.refreshToken = refreshToken
                institution?.tokenExpireDate = Date().addingTimeInterval(expiresIn - 10.0)
                institution?.apiScope = scope
                
                // Sync accounts
                if let institution = institution {
                    updateAccounts(institution: institution) { success, error in
                        if !success {
                            log.error("Error updating accounts: \(String(describing: error))")
                        }
                        
                        DispatchQueue.main.async {
                            completion(true, nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "Couldn't create institution so couldn't sync accounts")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
        task.resume()
    }
    
    static func refreshAccessToken(institution: Institution, completion: @escaping SuccessErrorBlock) {
        guard let refreshToken = institution.refreshToken else {
            completion(false, "missing refreshToken")
            return
        }
        
        let urlString = "\(subServerUrl)coinbase/refreshToken"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let parameters = "{\"refreshToken\":\"\(refreshToken)\"}"
        request.httpBody = parameters.data(using: .utf8)
        
        // TODO: Create enum types for each error
        let task = certValidatedSession.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw BalanceError.noData
                }
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject], let accessToken = JSONResult["accessToken"] as? String, accessToken.count > 0, let refreshToken = JSONResult["refreshToken"] as? String, refreshToken.count > 0, let expiresIn = JSONResult["expiresIn"] as? TimeInterval else {
                    throw BalanceError.jsonDecoding
                }
                
                // Update the model
                institution.accessToken = accessToken
                institution.refreshToken = refreshToken
                institution.tokenExpireDate = Date().addingTimeInterval(expiresIn - 10.0)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, maybeError)
                }
            }
        }
        
        task.resume()
    }
    
    static func updateAccounts(institution: Institution, completion: @escaping SuccessErrorBlock) {
        guard let accessToken = institution.accessToken else {
            completion(false, "missing access token")
            return
        }
        
        let urlString = "https://api.coinbase.com/v2/accounts"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("2017-05-19", forHTTPHeaderField: "CB-VERSION")
        
        // TODO: Create enum types for each error
        let task = certValidatedSession.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw BalanceError.noData
                }
                
                // Try to parse the JSON
                let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
                
                // Check for errors (they return an array, but as far as I know it's always one error
                if let errorDicts = jsonResult?["errors"] as? [[String: AnyObject]] {
                    for errorDict in errorDicts {
                        if let id = errorDict["id"] as? String, let coinbaseError = CoinbaseError(rawValue: id) {
                            switch coinbaseError {
                            case .personalDetailsRequired:
                                // TODO: Display message to user
                                throw coinbaseError
                            case .unverifiedEmail:
                                // TODO: Display message to user
                                throw coinbaseError
                            case .invalidScope:
                                // TODO: Display message to user
                                throw coinbaseError
                            case .authenticationError, .invalidToken, .revokedToken, .expiredToken:
                                institution.passwordInvalid = true
                                throw coinbaseError
                            default:
                                throw coinbaseError
                            }
                        } else {
                            throw (errorDict["id"] as? String) ?? BalanceError.unknownError
                        }
                    }
                }
                
                // Check for account data
                guard let accountDicts = jsonResult?["data"] as? [[String: AnyObject]] else {
                    throw BalanceError.jsonDecoding
                }
                
                // Create the CoinbaseAccount objects
                var coinbaseAccounts = [CoinbaseAccount]()
                for accountDict in accountDicts {
                    do {
                        let coinbaseAccount = try CoinbaseAccount(account: accountDict)
                        coinbaseAccounts.append(coinbaseAccount)
                    } catch {
                        log.error("Failed to parse account data: \(error)")
                    }
                }
                
                // Create native Account objects and update them
                self.processCoinbaseAccounts(coinbaseAccounts, institution: institution)
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
        task.resume()
    }
    
    static func processCoinbaseAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution) {
        // Add/update accounts
        for ca in coinbaseAccounts {
            // Calculate the number of decimals
            let decimals = Currency.rawValue(ca.currency).decimals
            let altDecimals = Currency.rawValue(ca.nativeCurrency).decimals
            
            // Calculate the integer value of the balance based on the decimals
            var balance = ca.balance
            balance = balance * Decimal(pow(10.0, Double(decimals)))
            let currentBalance = (balance as NSDecimalNumber).intValue
            
            var altBalance = ca.nativeBalance
            altBalance = altBalance * Decimal(pow(10.0, Double(altDecimals)))
            let altCurrentBalance = (altBalance as NSDecimalNumber).intValue
            
            // Initialize an Account object to insert the record
            AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: ca.id, sourceInstitutionId: "", accountTypeId: AccountType.depository, accountSubTypeId: nil, name: ca.name, currency: ca.currency, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: ca.nativeCurrency, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil)
        }
        
        // Remove accounts that no longer exist
        // TODO: In the future, when we have metadata associated with accounts / transactions, we'll need to
        // migrate that metadata to a new account if it is a replacement for an old one. In my case, my Provident
        // Credit Union at some point returned new accounts with new source account ids with better formatted names.
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = coinbaseAccounts.index(where: {$0.id == account.sourceAccountId})
            if index == nil {
                // This account doesn't exist in the coinbase response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
}

//THIS NEEDS TESTING
extension Institution {
    fileprivate var refreshTokenKey: String {
        return "refreshToken institutionId: \(institutionId)"
    }
    
    var refreshToken: String? {
        get {
            var refreshToken: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: refreshTokenKey) {
                refreshToken = dictionary["refreshToken"] as? String
            }
            
            log.debug("get refreshTokenKey: \(refreshTokenKey)  refreshToken: \(String(describing: refreshToken))")
            if refreshToken == nil {
                // We should always be getting an refresh token becasuse we never read it until after it's been written
                log.severe("Tried to read refresh token for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return refreshToken
        }
        set {
            log.debug("set refreshTokenKey: \(refreshTokenKey)  newValue: \(String(describing: newValue))")
            if let refreshToken = newValue {
                do {
                    try Locksmith.updateData(data: ["refreshToken": refreshToken], forUserAccount: refreshTokenKey)
                } catch {
                    log.severe("Couldn't update refreshToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if refreshToken != self.refreshToken {
                    log.severe("Saved access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: refreshTokenKey)
                } catch {
                    log.severe("Couldn't delete refreshToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: refreshTokenKey)
                if dictionary != nil {
                    log.severe("Deleted access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
    
    fileprivate static let tokenExpireDateKey = "tokenExpireDateKey"
    fileprivate var tokenExpireDate: Date {
        get {
            return UserDefaults.standard.object(forKey: Institution.tokenExpireDateKey) as? Date ?? Date.distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Institution.tokenExpireDateKey)
        }
    }
    
    var isTokenExpired: Bool {
        return Date().timeIntervalSince(tokenExpireDate) > 0.0
    }
    
    // Scope
    fileprivate static let apiScopeKey = "Institution.apiScopeKey"
    fileprivate var apiScope: String? {
        get {
            return UserDefaults.standard.string(forKey: Institution.apiScopeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Institution.apiScopeKey)
        }
    }
}

// MARK: Transactions

internal extension CoinbaseApi {
    internal static func fetchTransactions(accountID: String, institution: Institution, completionHandler: @escaping (_ transactions: [CoinbaseApi.Transaction]?, _ error: Error?) -> Void) {
        guard let accessToken = institution.accessToken else {
            completionHandler(nil, "missing access token")
            return
        }
        
        let urlString = "https://api.coinbase.com/v2/accounts/\(accountID)/transactions"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("2017-06-14", forHTTPHeaderField: "CB-VERSION")
        
        let task = certValidatedSession.dataTask(with: request) { data, response, error in
            do {
                guard let unwrappedData = data,
                          error == nil else {
                    throw "No data"
                }
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String : Any],
                      let transactionsJSON = JSONResult["data"] as? [[String: AnyObject]] else {
                    throw "JSON decoding failed"
                }
                
                // Transactions
                var transactions = [CoinbaseApi.Transaction]()
                for transactionJSON in transactionsJSON {
                    do {
                        let transaction = try CoinbaseApi.Transaction(dictionary: transactionJSON)
                        transactions.append(transaction)
                    } catch {
                        log.error("Failed to parse account data: \(error)")
                    }
                }
                
                DispatchQueue.main.async {
                    completionHandler(transactions, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
}

