//
//  BTCAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BTCAPI2Action: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension BTCAPI2Action {
    
    var host: String {
        return "https://blockchain.info/"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "rawaddr/\(credentials.address)"
        case .transactions(_):
            return ""
        }
    }
    
    var components: URLComponents? {
        return nil
    }
    
    var url: URL? {
        switch type {
        case .accounts:
            return URL(string: host + path)
        case .transactions(_):
            return nil
        }
    }
    
    var nonce: Int64 {
        return 0
    }
    
}
