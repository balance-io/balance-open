//
//  HitBTCAPIAction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct HitBTCAPIAction: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    let nonce: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension HitBTCAPIAction {
    
    var host: String {
        return "https://api.hitbtc.com"
    }
    
    var path: String {
        switch type {
        case .accounts:
        //            return "/trading/balance" TODO: validate
            return "/api/2/account/balance"
        case .transactions(_):
            return "/api/2/account/transactions"
        }
    }
    
    var url: URL? {
        return URL(string: host + path + validQuery)
    }
    
    var components: URLComponents? {
        return getBasicURLComponents(from: params)
    }
    
    private var params: [String: String] {
        let basicParams:  [String: String] = [
            "nonce" : String(nonce),
            "apikey": credentials.apiKey
        ]
        
        switch type {
        case .accounts:
            return basicParams
        case .transactions(_):
            return basicParams
        }
    }
    
    private var validQuery: String {
        guard let validQuery = self.query else {
            return ""
        }
        
        return "?" + validQuery
    }
    
}
