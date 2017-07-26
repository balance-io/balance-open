//
//  CoinbaseApi.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import AppKit
import Locksmith

typealias SuccessErrorBlock = (_ success: Bool, _ error: Error?) -> Void

fileprivate let connectionTimeout = 30.0
//fileprivate let subServerUrl = "http://localhost:8080/"
//fileprivate let subServerUrl = "https://bal-subscription-server-beta.appspot.com/"
fileprivate let subServerUrl = "https://www.balancemysubscription.com/"
fileprivate let clientId = "a6e15fbb0c3362b74360895f261fb079672c10eef79dcb72308c974408c5ce43"

// Save random state for current authentication request
fileprivate var lastState: String? = nil

fileprivate let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)

struct CoinbaseApi {

    static func authenticate() -> Bool {
        let redirectUri = "balancemymoney%3A%2F%2Fcoinbase"
        let responseType = "code"
        let scope = "wallet%3Auser%3Aread,wallet%3Aaccounts%3Aread"
        let state = String.random(32)
        let url = "https://www.coinbase.com/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&state=\(state)&response_type=\(responseType)&scope=\(scope)&account=all"
        
        do {
            _ = try NSWorkspace.shared.open(URL(string: url)!, options: [], configuration: [:])
        } catch {
            // TODO: Better error handling
            print("Error opening Coinbase authentication URL: \(error)")
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
        let urlString = "\(subServerUrl)coinbase/convertCode"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "POST"
        let parameters = "{\"code\":\"\(code)\"}"
        request.httpBody = parameters.data(using: .utf8)
        
        // TODO: Create enum types for each error
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw "No data"
                }

                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let accessToken = JSONResult["accessToken"] as? String, accessToken.length > 0, let refreshToken = JSONResult["refreshToken"] as? String, refreshToken.length > 0, let expiresIn = JSONResult["expiresIn"] as? TimeInterval else {
                    throw "JSON decoding failed"
                }
                
                // Create the institution and finish
                let institution = Institution(sourceId: .coinbase, sourceInstitutionId: "", name: "Coinbase", nameBreak: nil, primaryColor: nil, secondaryColor: nil, logoData: nil, accessToken: accessToken)
                institution?.refreshToken = refreshToken
                institution?.tokenExpireDate = Date().addingTimeInterval(expiresIn - 10.0)
                
                // Sync accounts
                if let institution = institution {
                    updateAccounts(institution: institution) { success, error in
                        if !success {
                            print("Error updating accounts: \(String(describing: error))")
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
        })
        
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
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw "No data"
                }
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let accessToken = JSONResult["accessToken"] as? String, accessToken.length > 0, let refreshToken = JSONResult["refreshToken"] as? String, refreshToken.length > 0, let expiresIn = JSONResult["expiresIn"] as? TimeInterval else {
                    throw "JSON decoding failed"
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
        })
        
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
        request.setValue("2017-06-14", forHTTPHeaderField: "CB-VERSION")
        
        // TODO: Create enum types for each error
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw "No data"
                }
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let accountDicts = JSONResult["data"] as? [[String: AnyObject]] else {
                    throw "JSON decoding failed"
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
        })
        
        task.resume()
    }
    
    static func processCoinbaseAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution) {
        // Add/update accounts
        for ca in coinbaseAccounts {
            // Calculate the number of decimals
            var decimals = 2
            if let currency = Currency(rawValue: ca.currency) {
                decimals = currency.decimals
            }
            
            var altDecimals = 2
            if let altCurrency = Currency(rawValue: ca.nativeCurrency) {
                altDecimals = altCurrency.decimals
            }
            
            // Calculate the integer value of the balance based on the decimals
            var balance = ca.balance
            balance = balance * Decimal(pow(10.0, Double(decimals)))
            let currentBalance = (balance as NSDecimalNumber).intValue
            
            var altBalance = ca.nativeBalance
            altBalance = altBalance * Decimal(pow(10.0, Double(altDecimals)))
            let altCurrentBalance = (altBalance as NSDecimalNumber).intValue
            
            // Initialize an Account object to insert the record
            _ = Account(institutionId: institution.institutionId, sourceId: institution.sourceId, sourceAccountId: ca.id, sourceInstitutionId: "", accountTypeId: AccountType.depository, accountSubTypeId: nil, name: ca.name, currency: ca.currency, decimals: decimals, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: ca.nativeCurrency, altDecimals: altDecimals, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil)
        }
        
        // Remove accounts that no longer exist
        // TODO: In the future, when we have metadata associated with accounts / transactions, we'll need to
        // migrate that metadata to a new account if it is a replacement for an old one. In my case, my Provident
        // Credit Union at some point returned new accounts with new source account ids with better formatted names.
        let accounts = Account.accountsForInstitution(institutionId: institution.institutionId)
        for account in accounts {
            let index = coinbaseAccounts.index(where: {$0.id == account.sourceAccountId})
            if index == nil {
                // This account doesn't exist in the coinbase response, so remove it
                Account.removeAccount(accountId: account.accountId)
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
            
            print("get refreshTokenKey: \(refreshTokenKey)  refreshToken: \(String(describing: refreshToken))")
            if refreshToken == nil {
                // We should always be getting an refresh token becasuse we never read it until after it's been written
                log.severe("Tried to read refresh token for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return refreshToken
        }
        set {
            print("set refreshTokenKey: \(refreshTokenKey)  newValue: \(String(describing: newValue))")
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
}
