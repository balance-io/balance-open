//
//  CoinbaseAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CoinbaseAPI2Action: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension CoinbaseAPI2Action {
    
    var host: String {
        return "https://api.coinbase.com/v2/"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "accounts"
        case .transactions(let accountID):
            let accountID = (accountID as? String) ?? ""
            return "accounts/\(accountID)/transactions"
        }
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
    var nonce: Int64 {
        return 0
    }
    
    var components: URLComponents {
        return URLComponents()
    }
    
}
