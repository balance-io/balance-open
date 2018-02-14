//
//  KucoinAPIAction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/13/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KucoinAPIAction: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    let nonce: Int64 = Int64(Date().timeIntervalSince1970 * 1000)

    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension KucoinAPIAction {
    
    var host: String {
        return "https://api.kucoin.com"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "/v1/account/balances"
        case .transactions(let currency):
            guard let currency = currency as? String else {
                return ""
            }
            
            return "/v1/account/\(currency)/wallet/records"
        }
    }
    
    var url: URL? {
        return URL.init(string: host + path)
    }
    
    var components: URLComponents? {
        return nil
    }
    
}
