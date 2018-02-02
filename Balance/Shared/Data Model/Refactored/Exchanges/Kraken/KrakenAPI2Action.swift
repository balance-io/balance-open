//
//  KrakenAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/26/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KrakenApiAction {
    
    let type: ApiRequestType
    let credentials: Credentials
    let nonce: Int64 = Int64(Date().timeIntervalSince1970 * 1000000000)
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
}

extension KrakenApiAction: APIAction {
    private var params: [String: String] {
        switch type {
        case .accounts, .transactions:
            return [
                "nonce" : "\(nonce)"
            ]
        }
    }
    
    var host: String {
        return "https://api.kraken.com"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "/0/private/Balance"
        case .transactions:
            return "/0/private/Ledgers"
        }
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
    var components: URLComponents {
        return getBasicURLComponents(from: params)
    }

}
