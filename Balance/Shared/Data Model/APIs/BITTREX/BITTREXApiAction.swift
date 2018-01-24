//
//  BITTREXApiAction.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BITTREXApiAction {
    case getCurrencies
    case getBalances
    case getBalance(currency: String)
    case getAllDepositHistory
    case getDepositHistory(currency: String)
    case getAllWithdrawalHistory
    case getWithdrawalHistory(currency: String)
    
    var host: String {
        return "https://bittrex.com/"
    }
    
    var apiVersion: String {
        return "api/v1.1/"
    }
    
    // API doc suggest 3 kinds of methods acording to the action(account, public, market)
    var methodType: String {
        switch self {
        case .getBalances, .getBalance(_), .getAllDepositHistory, .getDepositHistory(_), .getAllWithdrawalHistory, .getWithdrawalHistory(_):
            return "account/"
        case .getCurrencies:
            return "public/"
        }
    }
    
    var path: String {
        switch self {
        case .getBalances, .getBalance(_):
            return "getbalances"
        case .getAllDepositHistory, .getDepositHistory(_):
            return "getdeposithistory"
        case .getAllWithdrawalHistory, .getWithdrawalHistory(_):
            return "getwithdrawalhistory"
        case .getCurrencies:
            return "getcurrencies"
        }
    }
    
    var fullPath: String {
        return host + apiVersion + methodType + path
    }
    
    func params(for action: BITTREXApiAction, apiKey: String) -> [String: Any] {
        switch self {
        case .getBalances, .getCurrencies, .getAllDepositHistory, .getAllWithdrawalHistory:
            return [
                "apikey" : apiKey,
                "nonce" : nonce
            ]
        case .getBalance(let currency), .getDepositHistory(let currency), .getWithdrawalHistory(let currency):
            return [
                "apikey": apiKey,
                "nonce" : nonce,
                "currency": currency,
            ]
        }
    }
    
    var nonce: Int64 {
        return Int64(Date().timeIntervalSince1970 * 10000)
    }
    
}
