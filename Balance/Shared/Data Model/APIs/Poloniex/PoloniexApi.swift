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

//typealias SuccessErrorBlock2 = (_ success: Bool, _ error: Error?) -> Void

fileprivate let tradingURL = URL(string: "https://poloniex.com/tradingApi")!
//typealias SuccessErrorBlock = (_ success: Bool, _ error: Error) -> Void

enum PoloniexCommands: String {
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

/*
 All calls to the trading API are sent via HTTP POST to https://poloniex.com/tradingApi and must contain the following headers:
 
 Key - Your API key.
 Sign - The query's POST data signed by your key's "secret" according to the HMAC-SHA512 method.
 
 
 Additionally, all queries must include a "nonce" POST parameter. The nonce parameter is an integer which must always be greater than the previous nonce used.
 
 */

struct PoloniexApi: ExchangeApi {
    func authenticate(secret: String, key: String) {
        assert(false, "implement")
    }
    
    func authenticate(secret: String, key: String, passphrase: String) {
        assert(false, "implement")
    }
    
    func findError(data: Data) -> String? {
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                throw "JSON decoding failed"
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
    
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (Bool) -> Void) {
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
        }
        PoloniexApi.authenticate(secret: secret, key: key, closeBlock: closeBlock)
    }

    //TODO:
    
    //Poloniex doesn't have an authenticate method "per-se" so we use the returnBalances call to validate the key-secret pair for login
    static func authenticate(secret: String, key: String, closeBlock: @escaping (Bool) -> Void) {
        
        let requestInfo = PoloniexApi.createRequestBodyandHash(params: ["command":PoloniexCommands.returnCompleteBalances.rawValue],secret: secret, key: key)
        let urlRequest = PoloniexApi.assembleTradingRequest(key: key, body: requestInfo.body, hashBody: requestInfo.signedBody)
        let datatask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            do {
                if let safeData = data {
                    //if error exists should be reported to UI data
                    _ = findError
                    // Create the institution and finish (we do not have access tokens)
                    let institution = InstitutionRepository.si.institution(source: .poloniex, sourceInstitutionId: "", name: "Poloniex")
                    institution?.secret = secret
                    institution?.apiKey = key
                    
                    //create accounts
                    let poloniexAccounts = try createPoloniexAccounts(data: safeData)
                    processPoloniexAccounts(accounts: poloniexAccounts, institution: institution!)
                    closeBlock(true)
                } else {
                    print("Poloniex Error: \(String(describing: error))")
                    print("Poloniex Data: \(String(describing: data))")
                    closeBlock(false)
                    throw "Error \(String(describing:error))"
                }
            }
            catch {
                log.error("Failed to Poloniex balance login data: \(error)")
            }
        })
        datatask.resume()
    }
    
    private static func createRequestBodyandHash(params: [String: String], secret: String, key: String) -> (body: String, signedBody: String) {
        let nonce = Int(Date().timeIntervalSince1970*10000)

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
    
    private static func assembleTradingRequest(key: String, body: String, hashBody: String) -> URLRequest {
        var request = URLRequest(url: tradingURL)
        request.httpMethod = "POST"
        request.setValue(key, forHTTPHeaderField: "Key")
        request.setValue(hashBody, forHTTPHeaderField: "Sign")
        request.httpBody = body.data(using: .utf8)!
        return request
    }
    
    static func fetchBalances(secret: String, key: String, institution: Institution, completion: @escaping SuccessErrorBlock) {
        let requestInfo = PoloniexApi.createRequestBodyandHash(params: ["command":PoloniexCommands.returnCompleteBalances.rawValue],secret: secret, key: key)
        let urlRequest = PoloniexApi.assembleTradingRequest(key: key, body: requestInfo.body, hashBody: requestInfo.signedBody)
        
        let datatask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?) in
            do {
                if let safeData = data {
                    //create accounts
                    let poloniexAccounts = try createPoloniexAccounts(data: safeData)
                    processPoloniexAccounts(accounts: poloniexAccounts, institution: institution)
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
        })
        datatask.resume()
    }
    
    static var poloniexInstitution: PoloniexInstitution {
        get {
            return PoloniexInstitution()
        }
    }
    
    class PoloniexInstitution: ApiInstitution {
        let source: Source = .poloniex
        let sourceInstitutionId: String = ""
        
        var currencyCode: String = ""
        var usernameLabel: String = ""
        var passwordLabel: String = ""
        var name: String = ""
        var products: [String] = []
        var type: String = ""
        var url: String? = "https://poloniex.com/login"
        var fields: [Field]
        
        init() {
            let keyField = Field(name: "Key", label: "Key", type: "key", value: nil)
            let secretField = Field(name: "Secret", label: "Secret", type: "secret", value: nil)
            self.fields = [keyField, secretField]
        }
    }
    
}

fileprivate func createPoloniexAccounts(data: Data) throws -> [PoloniexAccount] {
    //create accounts
    guard let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
        throw "JSON decoding failed"
    }
    var poloniexAccounts = [PoloniexAccount]()
    let filteredAccountDicts = dict.filter({
        let (_, dictionary) = $0
        let availableAmount: String = dictionary["available"] as! String
        let availableDecimal = Double(availableAmount)
        return availableDecimal! != 0.0
    })
    for (currencyShortName, dictionary) in filteredAccountDicts {
        do {
            let poloniexAccount = try PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currencyShortName, type: AccountType.exchange)
            poloniexAccounts.append(poloniexAccount)
        } catch {
            log.error("Failed to parse account data: \(error)")
        }
    }
    return poloniexAccounts
}

fileprivate func processPoloniexAccounts(accounts: [PoloniexAccount],institution: Institution) {
    for account in accounts {
        // Calculate the number of decimals
        _ = PoloniexAccount.getAccountEquivalent(account:account, institution: institution)
    }
    let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
    for account in accounts {
        let index = accounts.index(where: {$0.currency == account.currency})
        if index == nil {
            // This account doesn't exist in the coinbase response, so remove it
            AccountRepository.si.delete(account: account)
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
    
    static func getAccountEquivalent(account: PoloniexAccount, institution: Institution) -> Account {
        // Calculate the integer value of the balance based on the decimals
        let currentBalance = account.balance
        let altCurrentBalance = account.altBalance
        
        // Poloniex doesn't have id's per-se, the id a coin is the coin symbol itself
        let newAccount = AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.currency.name, sourceInstitutionId: "", accountTypeId: AccountType.exchange, accountSubTypeId: nil, name: account.currency.name, currency: account.currency.name, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: account.altCurrency.name, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil)
        return newAccount!
    }
}

extension Institution {
    fileprivate var apiKeyKey: String {
        return "apiKey institutionId: \(institutionId)"
    }
    public var apiKey: String? {
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
    
    fileprivate var secretKey: String {
        return "secret institutionId: \(institutionId)"
    }
    public var secret: String? {
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
