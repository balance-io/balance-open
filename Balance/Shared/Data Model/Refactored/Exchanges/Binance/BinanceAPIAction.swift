//
//  BinanceAPIAction.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BinanceAPIAction: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    let nonce: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension BinanceAPIAction {
    
    var host: String {
        return "https://api.binance.com"
    }
    
    var url: URL? {
        switch type {
        case .accounts:
            return URL(string: host + path + validQuery)
        default:
            return nil
        }
    }
    
    var components: URLComponents? {
        return getBasicURLComponents(from: params)
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "/api/v3/account"
        case .transactions(_):
            return ""
        }
    }
    
    private var validQuery: String {
        guard let validQuery = self.query else {
            return ""
        }
        
        return "?" + validQuery
    }
    
    private var params: [String: String] {
        return [
            "timestamp": String(nonce),
        ]
    }
    
}

extension BinanceAPIAction {
    
    private var depositPath: String {
        return "/wapi/v3/depositHistory.html"
    }
    
    private var withdrawalPath: String {
        return "/wapi/v3/withdrawHistory.html"
    }
    
    var depositTransactionURL: URL? {
        return URL(string: host + depositPath + validQuery)
    }
    
    var withdrawalTransactionURL: URL? {
        return URL(string: host + withdrawalPath + validQuery)
    }
    
}
