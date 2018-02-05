//
//  BitfinexAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/5/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BitfinexAPI2Action: APIAction {
    
    let nonce: Int64 = Int64(Date().timeIntervalSince1970)
    let type: ApiRequestType
    let credentials: Credentials
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension BitfinexAPI2Action {
    
    var host: String {
        return "https://api.bitfinex.com/"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "v2/auth/r/wallets"
        case .transactions(_):
            return "v2/auth/r/movements/hist"
        }
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
    var components: URLComponents {
        return URLComponents()
    }
    
}
