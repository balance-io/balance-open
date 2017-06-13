//
//  PoloniexAPI.swift
//  BalanceForBlockchain
//
//  Created by Raimon Lapuente on 13/06/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Security

fileprivate let tradingURL = URL(string: "https://poloniex.com/tradingApi")!
fileprivate let APIKEY = "U78QPSJT-9JW9F28T-IMQW7PI8-5VUKB8ZV"

typealias SuccessErrorBlock = (_ success: Bool, _ error: Error) -> Void

enum PoloniexCommands {
    case returnBalances = "returnBalances"
    case returnCompleteBalances = "returnCompleteBalances"
    case returnDepositAddresses = "returnDepositAddresses"
    case generateNewAddress = "generateNewAddress"
    case returnDepositsWithdrawals = "returnDepositsWithdrawals"
    case returnOpenOrders = "returnOpenOrders"
    case returnTradeHistory = "returnTradeHistory"
    case returnOrderTrades = "returnOrderTrades"
    case buy = "buy"
    case sell = "sell"
    case cancelOrder = "cancelOrder"
    case moveOrder = "moveOrder"
    case withdraw = "withdraw"
    case returnFeeInfo = "returnFeeInfo"
    case returnAvailableAccountBalances = "returnAvailableAccountBalances"
    case returnTradableBalances = "returnTradableBalances"
    case transferBalance = "transferBalance"
    case returnMarginAccountSummary = "returnMarginAccountSummary"
    case marginBuy = "marginBuy"
    case marginSell = "marginSell"
    case getMarginPosition = "getMarginPosition"
    case closeMarginPosition = "closeMarginPosition"
    case createLoanOffer = "createLoanOffer"
    case cancelLoanOffer = "cancelLoanOffer"
    case returnOpenLoanOffers = "returnOpenLoanOffers"
    case returnActiveLoans = "returnActiveLoans"
    case returnLendingHistory = "returnLendingHistory"
    case toggleAutoRenew = "toggleAutoRenew"
}

struct PoloniexAPI {
    
    let body: String
    let hash: String
    var bodyData: Data {
        return body.data(using: .utf8)!
    }
    var urlRequest: URLRequest {
        var request = URLRequest(url: tradingURL)
        request.setValue(APIKEY, forHTTPHeaderField: "Key")
        request.setValue(hash, forHTTPHeaderField: "Sign")
        request.httpBody = bodyData
        request.httpMethod = "POST"
        return request
    }
    
    /*
     All calls to the trading API are sent via HTTP POST to https://poloniex.com/tradingApi and must contain the following headers:
     
     Key - Your API key.
     Sign - The query's POST data signed by your key's "secret" according to the HMAC-SHA512 method.
     

     Additionally, all queries must include a "nonce" POST parameter. The nonce parameter is an integer which must always be greater than the previous nonce used.
     
     */
    init(params: [String: String], secret: String) {
        self.keys = keys
        
        let nonce = Date().timeIntervalSince1970
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        queryItems.append(URLQueryItem(name: "nonce", value: "\(nonce)"))
        var components = URLComponents()
        components.queryItems = queryItems
        let body = components.query!
        let hash = body.hmac(algorithm: HMACECase.SHA512, key: keys.secret)
        
        self.body = body
        self.hash = hash
    }
    
}

//from https://stackoverflow.com/questions/24099520/commonhmac-in-swift

enum HMACECase {
    case SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: CInt = 0
        switch self {
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: HMACECase, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
}
