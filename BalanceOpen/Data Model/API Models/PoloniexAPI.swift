//
//  PoloniexAPI.swift
//  BalanceForBlockchain
//
//  Created by Raimon Lapuente on 13/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Security
import Locksmith

//typealias SuccessErrorBlock2 = (_ success: Bool, _ error: Error?) -> Void

protocol exchangeAPI {
    static func authenticate(secret: String, key: String)
//    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock)
//    static func refreshAccessToken(institution: Institution, completion: @escaping SuccessErrorBlock)
//    static func updateAccounts(institution: Institution, completion: @escaping SuccessErrorBlock)
//    static func processAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution)
}

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

struct PoloniexAPI: exchangeAPI {
    
    //Poloniex doesn't have an authenticate method "per-se" so we use the returnBalances call to validate the key-secret pair for login
    static func authenticate(secret: String, key: String) {
        
        let requestInfo = PoloniexAPI.createRequestBodyandHash(params: ["command":PoloniexCommands.returnCompleteBalances.rawValue],secret: secret, key: key)
        let urlRequest = PoloniexAPI.assembleTradingRequest(key: key, body: requestInfo.body, hashBody: requestInfo.signedBody)
        let datatask = URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?) in
            do {
                if let safeInfo = data {
                    print("Poloniex Response: \(String(describing: String(data:safeInfo, encoding:.utf8)))")
                    
                    // Create the institution and finish (we do not have access tokens
                    let institution = Institution(sourceId: .poloniex, sourceInstitutionId: "", name: "Poloniex", nameBreak: nil, primaryColor: .green, secondaryColor: nil, logoData: nil, accessToken: "")
                    institution?.Secret = secret
                    institution?.APIkey = key
                    
                    //create accounts
                    guard let dict = try JSONSerialization.jsonObject(with: safeInfo, options: .mutableContainers) as? [String: AnyObject], let accountDict = dict as? [String:[String:String]] else {
                        throw "JSON decoding failed"
                    }
                    var poloniexAccounts = [PoloniexAccount]()
                    let filteredAccountDicts = dict.filter({
                        do {
                            let (_, dictionary) = $0
                            let availableAmount: String = dictionary["available"] as! String
                            let availableDecimal = Double(availableAmount)
                            return availableDecimal! != 0.0
                        } catch {
                            log.error("Failed to filter data: \(error)")
                            return false
                        }
                        
                    })
                    for (currency, dictionary) in filteredAccountDicts {
                        do {
                            let poloniexAccount = try PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currency: currency, type: AccountType.exchange)
                            poloniexAccounts.append(poloniexAccount)
                        } catch {
                            log.error("Failed to parse account data: \(error)")
                        }
                    }
                    processPoloniexAccounts(accounts: poloniexAccounts, institution: institution!)
                } else {
                    print("Poloniex Error: \(String(describing: error))")
                    print("Poloniex Data: \(String(describing: data))")
                }
            }
            catch {
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
        let signedPOST = PoloniexAPI.hmac(body:body, algorithm: HMACECase.SHA512, key: secret)
        
        return (body, signedPOST)
    }
    
    private static func assembleTradingRequest(key: String, body: String, hashBody: String) -> URLRequest {
        var request = URLRequest(url: tradingURL)
        request.httpMethod = "POST"
        request.setHeaders(headers: ["Key":key,"Sign":hashBody])
        request.httpBody = body.data(using: .utf8)!
        return request
    }
    
    private static func hmac(body: String, algorithm: HMACECase, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let str = body.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength))
        
        CCHmac(algorithm.HMACAlgorithm, cKey!, Int(strlen(cKey!)), str!, Int(strlen(str!)), &result)
        let digest = result.map { String(format: "%02hhx", $0) }
        
        return digest.joined()
    }
    
    func fetchBalances(secret: String, APIKey: String) {
        let requestInfo = PoloniexAPI.createRequestBodyandHash(params: ["command":PoloniexCommands.returnBalances.rawValue],secret: secret, key: APIKey)
        let urlRequest = PoloniexAPI.assembleTradingRequest(key: APIKey, body: requestInfo.body, hashBody: requestInfo.signedBody)
        let datatask = URLSession.shared.dataTask(with: urlRequest) { (data:Data?, response:URLResponse?, error:Error?) in
            if let safeInfo = data {
                print("Poloniex Response: \(String(describing: String(data:safeInfo, encoding:.utf8)))")
            }
            else {
                print("Poloniex Error: \(String(describing: error))")
                print("Poloniex Data: \(String(describing: data))")
            }
        }
        datatask.resume()
    }
    
}

fileprivate func processPoloniexAccounts(accounts: [PoloniexAccount],institution: Institution) {
    for account in accounts {
        // Calculate the number of decimals
        var decimals = 2
        if let currency = Currency(rawValue: account.currency) {
            decimals = currency.decimals
        }
        var altDecimals = 2
        if let altCurrency = Currency(rawValue: "BTC") {
            altDecimals = altCurrency.decimals
        }
        
        // Calculate the integer value of the balance based on the decimals
        var balance = account.available
        balance = balance * Decimal(pow(10.0, Double(decimals)))
        let currentBalance = (balance as NSDecimalNumber).intValue
        
        var altBalance = account.btcValue
        altBalance = altBalance * Decimal(pow(10.0, Double(altDecimals)))
        let altCurrentBalance = (altBalance as NSDecimalNumber).intValue
        
        //Poloniex doesn't have id's per-se, the id a coin is the coin symbol itself
        _ = Account(institutionId: institution.institutionId, sourceId: institution.sourceId, sourceAccountId: account.currency, sourceInstitutionId: "", accountTypeId: AccountType.exchange, accountSubTypeId: nil, name: account.currency, currency: account.currency, decimals: decimals, currentBalance: currentBalance, availableBalance: nil, number: nil, altCurrency: Currency.btc.rawValue, altDecimals: altDecimals, altCurrentBalance: altCurrentBalance, altAvailableBalance: nil)
    }
    let accounts = Account.accountsForInstitution(institutionId: institution.institutionId)
    for account in accounts {
        let index = accounts.index(where: {$0.currency == account.currency})
        if index == nil {
            // This account doesn't exist in the coinbase response, so remove it
            Account.removeAccount(accountId: account.accountId)
        }
    }
}

extension Institution {
    fileprivate var APIkeyKey: String {
        return "APIkey institutionId: \(institutionId)"
    }
    var APIkey: String? {
        get {
            var APIkey: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: APIkeyKey) {
                APIkey = dictionary["APIkey"] as? String
            }
            
            print("get APIkeyKey: \(APIkeyKey)  APIKey: \(String(describing: APIkey))")
            if APIkey == nil {
                // We should always be getting an APIkey becasuse we never read it until after it's been written
                log.severe("Tried to read APIkey for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return APIkey
        }
        set {
            print("set APIkeyKey: \(APIkeyKey)  newValue: \(String(describing: newValue))")
            if let APIkey = newValue {
                do {
                    try Locksmith.updateData(data: ["APIkey": APIkey], forUserAccount: APIkeyKey)
                } catch {
                    log.severe("Couldn't update APIkey keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if APIkey != self.APIkey {
                    log.severe("Saved APIkeyKey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: APIkeyKey)
                } catch {
                    log.severe("Couldn't delete APIkey keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: APIkeyKey)
                if dictionary != nil {
                    log.severe("Deleted APIkey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
    
    fileprivate var SecretKey: String {
        return "Secret institutionId: \(institutionId)"
    }
    var Secret: String? {
        get {
            var Secret: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: SecretKey) {
                Secret = dictionary["Secret"] as? String
            }
            
            print("get SecretKey: \(SecretKey)  Secret: \(String(describing: Secret))")
            if Secret == nil {
                // We should always be getting an Secret becasuse we never read it until after it's been written
                log.severe("Tried to read SecretKey for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return Secret
        }
        set {
            print("set SecretKey: \(SecretKey)  newValue: \(String(describing: newValue))")
            if let Secret = newValue {
                do {
                    try Locksmith.updateData(data: ["Secret": Secret], forUserAccount: SecretKey)
                } catch {
                    log.severe("Couldn't update Secret keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if Secret != self.Secret {
                    log.severe("Saved SecretKey for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: SecretKey)
                } catch {
                    log.severe("Couldn't delete Secret keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: SecretKey)
                if dictionary != nil {
                    log.severe("Deleted Secret for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
}
//from https://stackoverflow.com/questions/24099520/commonhmac-in-swift

fileprivate enum HMACECase {
    case SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var algorithm: Int = 0
        switch self {
        case .SHA512:   algorithm = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(algorithm)
    }
    
    var digestLength: Int {
        var length: CInt = 0
        switch self {
        case .SHA512:
            length = CC_SHA512_DIGEST_LENGTH
        }
        return Int(length)
    }
}
