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
typealias SuccessErrorBlock = (_ success: Bool, _ error: Error) -> Void

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
    
    let body: String
    let hash: String
    let secret: String
    let APIKey: String
    var bodyData: Data {
        return body.data(using: .utf8)!
    }
    var urlRequest: URLRequest {
        var request = URLRequest(url: tradingURL)
        request.httpMethod = "POST"
        request.setHeaders(headers: ["Key":APIKey,"Sign":hash])
        request.httpBody = bodyData
        return request
    }
    
    init(params: [String: String], secret: String, key: String) {
        
        self.secret = secret
        self.APIKey = key
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
        
        self.body = body
        self.hash = signedPOST
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
        let datatask = URLSession.shared.dataTask(with: self.urlRequest) { (data:Data?, response:URLResponse?, error:Error?) in
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
