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
    static func authenticate() -> Bool
    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock)
    static func refreshAccessToken(institution: Institution, completion: @escaping SuccessErrorBlock)
    static func updateAccounts(institution: Institution, completion: @escaping SuccessErrorBlock)
    static func processAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution)
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

struct PoloniexAPI {

    let secret: String
    let APIKey: String
    
    init(secret:String, key: String) {
        
        self.secret = secret
        self.APIKey = key
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
    
    func fetchBalances() {
        let requestInfo = PoloniexAPI.createRequestBodyandHash(params: ["command":PoloniexCommands.returnBalances.rawValue],secret: self.secret, key: self.APIKey)
        let urlRequest = PoloniexAPI.assembleTradingRequest(key: self.APIKey, body: requestInfo.body, hashBody: requestInfo.signedBody)
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
