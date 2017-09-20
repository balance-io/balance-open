//
//  PoloniexApi.swift
//  BalanceForBlockchain
//
//  Created by Raimon Lapuente on 13/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Security
import Locksmith

/*
 All calls to the trading API are sent via HTTP POST to https://poloniex.com/tradingApi and must contain the following headers:
 
 Key - Your API key.
 Sign - The query's POST data signed by your key's "secret" according to the HMAC-SHA512 method.
 
 
 Additionally, all queries must include a "nonce" POST parameter. The nonce parameter is an integer which must always be greater than the previous nonce used.
 
 */

class PoloniexApi: ExchangeApi {
    
    fileprivate enum Commands: String {
        case returnBalances
        case returnCompleteBalances
        case returnDepositAddresses
        case generateNewAddress
        case returnDepositsWithdrawals
        case returnOpenOrders
        case returnTradeHistory
        case returnOrderTrades
        case buy
        case sell
        case cancelOrder
        case moveOrder
        case withdraw
        case returnFeeInfo
        case returnAvailableAccountBalances
        case returnTradableBalances
        case transferBalance
        case returnMarginAccountSummary
        case marginBuy
        case marginSell
        case getMarginPosition
        case closeMarginPosition
        case createLoanOffer
        case cancelLoanOffer
        case returnOpenLoanOffers
        case returnActiveLoans
        case returnLendingHistory
        case toggleAutoRenew
    }
    
    // MARK: - Constants -
    
    fileprivate let tradingURL = URL(string: "https://poloniex.com/tradingApi")!
    
    // MARK: - Properties -
    
    fileprivate var secret: String
    fileprivate var key: String
    
    // MARK: - Lifecycle -
    
    init() {
        self.secret = ""
        self.key = ""
    }

    init(secret: String, key: String) {
        self.secret = secret
        self.key = key
    }
    
    // MARK: - Public -
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Poloniex")
        var secretField : String?
        var keyField : String?
        for field in loginStrings {
            if field.type == "key" {
                keyField = field.value
            } else if field.type == "secret" {
                secretField = field.value
            } else {
                assert(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values")
            }
        }
        guard let secret = secretField, let key = keyField else {
            assert(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values")
            closeBlock(false, "wrong fields are passed into the poloniex auth, we require secret and key fields and values", nil)
            return
        }
        do {
            try authenticate(secret: secret, key: key, closeBlock: closeBlock)
        } catch {
            
        }
    }
    
    func fetchBalances(institution: Institution, completion: @escaping SuccessErrorBlock) {
        let requestInfo = createRequestBodyandHash(params: ["command": Commands.returnCompleteBalances.rawValue], secret: secret, key: key)
        let urlRequest = assembleTradingRequest(key: key, body: requestInfo.body, hashBody: requestInfo.signedBody)
        
        let datatask = certValidatedSession.dataTask(with: urlRequest) { data, response, error in
            do {
                if let safeData = data {
                    //create accounts
                    let poloniexAccounts = try self.parsePoloniexAccounts(data: safeData)
                    self.processPoloniexAccounts(accounts: poloniexAccounts, institution: institution)
                } else {
                    print("Poloniex Error: \(String(describing: error))")
                    print("Poloniex Data: \(String(describing: data))")
                }
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
            catch {
                log.error("Failed to Poloniex balance data: \(error)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        datatask.resume()
    }
    
    // MARK: - Private -
    
    fileprivate func findError(data: Data) -> String? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                throw PoloniexApi.CredentialsError.bodyNotValidJSON
            }
            if dict.keys.count == 1 {
                if let errorDict = dict["error"] {
                    return errorDict as? String
                }
            }
        } catch {
            return nil
        }
        return nil
    }
    
    // Poloniex doesn't have an authenticate method "per-se" so we use the returnBalances call to validate the key-secret pair for login
    fileprivate func authenticate(secret: String, key: String, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) throws {
        self.secret = secret
        self.key = key
        
        let requestInfo = createRequestBodyandHash(params: ["command": Commands.returnCompleteBalances.rawValue], secret: secret, key: key)
        let urlRequest = assembleTradingRequest(key: key, body: requestInfo.body, hashBody: requestInfo.signedBody)
        let datatask = certValidatedSession.dataTask(with: urlRequest) { data, response, error in
            do {
                if let httpResponse = response as? HTTPURLResponse {
                    if case 400 = httpResponse.statusCode {
                        throw PoloniexApi.CredentialsError.incorrectLoginCredentials
                    } else if case 403 = httpResponse.statusCode {
                        throw PoloniexApi.CredentialsError.incorrectLoginCredentials
                    }
                }
                
                if let safeData = data {
                    //if error exists should be reported to UI data
                    if let error = self.findError(data: safeData) {
                        print("\(error)")
                        throw PoloniexApi.CredentialsError.incorrectLoginCredentials
                    }
                    // Create the institution and finish (we do not have access tokens)
                    if let institution = InstitutionRepository.si.institution(source: .poloniex, sourceInstitutionId: "", name: "Poloniex") {
                        institution.secret = secret
                        institution.apiKey = key
                        
                        //create accounts
                        let poloniexAccounts = try self.parsePoloniexAccounts(data: safeData)
                        self.processPoloniexAccounts(accounts: poloniexAccounts, institution: institution)
                        async {
                            closeBlock(true, nil, institution)
                        }
                    } else {
                        throw "Error creating institution"
                    }
                } else {
                    print("Poloniex Error: \(String(describing: error))")
                    print("Poloniex Data: \(String(describing: data))")
                    throw PoloniexApi.CredentialsError.bodyNotValidJSON
                }
            } catch {
                log.error("Failed to Poloniex balance login data: \(error)")
                async {
                    closeBlock(false, error, nil)
                }
            }
        }
        datatask.resume()
    }
    
    fileprivate func createRequestBodyandHash(params: [String: String], secret: String, key: String) -> (body: String, signedBody: String) {
        let nonce = Int(Date().timeIntervalSince1970 * 10000)

        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        queryItems.append(URLQueryItem(name: "nonce", value: "\(nonce)"))
        
        var components = URLComponents()
        components.queryItems = queryItems
        
        let body = components.query!
        let signedPost = CryptoAlgorithm.sha512.hmac(body: body, key: secret)
        
        return (body, signedPost)
    }
    
    fileprivate func assembleTradingRequest(key: String, body: String, hashBody: String) -> URLRequest {
        var request = URLRequest(url: tradingURL)
        request.httpMethod = "POST"
        request.setValue(key, forHTTPHeaderField: "Key")
        request.setValue(hashBody, forHTTPHeaderField: "Sign")
        request.httpBody = body.data(using: .utf8)!
        return request
    }
    
    fileprivate func parsePoloniexAccounts(data: Data) throws -> [PoloniexAccount] {
        guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
            throw PoloniexApi.CredentialsError.bodyNotValidJSON
        }
        
        var poloniexAccounts = [PoloniexAccount]()
        for (currencyShortName, dictionary) in dict {
            do {
                if let dictionary = dictionary as? [String: AnyObject] {
                    let poloniexAccount = try PoloniexAccount(dictionary: dictionary, currencyShortName: currencyShortName, type: .exchange)
                    poloniexAccounts.append(poloniexAccount)
                }
            } catch {
                log.error("Failed to parse account data: \(error)")
            }
        }
        return poloniexAccounts
    }
    
    fileprivate func processPoloniexAccounts(accounts: [PoloniexAccount], institution: Institution) {
        for account in accounts {
            // Create or upload the local account object
            account.updateLocalAccount(institution: institution)
        }
        
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = accounts.index(where: {$0.currency == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
}

extension PoloniexAccount {
    var altCurrency: Currency {
        return Currency.rawValue(shortName: "BTC")
    }
    
    var balance: Int {
        let balance = available * Decimal(pow(10.0, Double(currency.decimals)))
        return (balance as NSDecimalNumber).intValue
    }
    
    var altBalance: Int {
        let altBalance = btcValue * Decimal(pow(10.0, Double(altCurrency.decimals)))
        return (altBalance as NSDecimalNumber).intValue
    }
    
    @discardableResult func updateLocalAccount(institution: Institution) -> Account? {
        // Calculate the integer value of the balance based on the decimals
        let currentBalance = balance
        let altCurrentBalance = altBalance
        
        // Poloniex doesn't have id's per-se, the id a coin is the coin symbol itself
        if let newAccount = AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: currency.name, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: currency.name, currency: currency.name, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: altCurrency.name, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil) {
            
            // Hide unpoplular currencies that have a 0 balance
            if currency != Currency.btc && currency != Currency.eth {
                newAccount.isHidden = (currentBalance == 0)
            }
            
            return newAccount
        }
        return nil
    }
}

extension Institution {
    fileprivate var apiKeyKey: String { return "apiKey institutionId: \(institutionId)" }
    var apiKey: String? {
        get {
            var apiKey: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: apiKeyKey) {
                apiKey = dictionary["apiKey"] as? String
            }
            
            print("get apiKeyKey: \(apiKeyKey)  APIKey: \(String(describing: apiKey))")
            if apiKey == nil {
                // We should always be getting an apiKey becasuse we never read it until after it's been written
                log.severe("Tried to read APIkey for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return apiKey
        }
        set {
            print("set apiKeyKey: \(apiKeyKey)  newValue: \(String(describing: newValue))")
            if let apiKey = newValue {
                do {
                    try Locksmith.updateData(data: ["apiKey": apiKey], forUserAccount: apiKeyKey)
                } catch {
                    log.severe("Couldn't update APIkey keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if apiKey != self.apiKey {
                    log.severe("Saved apiKeyKey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: apiKeyKey)
                } catch {
                    log.severe("Couldn't delete APIkey keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: apiKeyKey)
                if dictionary != nil {
                    log.severe("Deleted APIkey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
    
    fileprivate var secretKey: String { return "secret institutionId: \(institutionId)" }
    var secret: String? {
        get {
            var secret: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: secretKey) {
                secret = dictionary["secret"] as? String
            }
            
            print("get secretKey: \(secretKey)  secret: \(String(describing: secret))")
            if secret == nil {
                // We should always be getting an secret becasuse we never read it until after it's been written
                log.severe("Tried to read secretKey for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return secret
        }
        set {
            print("set secretKey: \(secretKey)  newValue: \(String(describing: newValue))")
            if let secret = newValue {
                do {
                    try Locksmith.updateData(data: ["secret": secret], forUserAccount: secretKey)
                } catch {
                    log.severe("Couldn't update secret keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if secret != self.secret {
                    log.severe("Saved secretKey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: secretKey)
                } catch {
                    log.severe("Couldn't delete secret keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: secretKey)
                if dictionary != nil {
                    log.severe("Deleted secret for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
}
