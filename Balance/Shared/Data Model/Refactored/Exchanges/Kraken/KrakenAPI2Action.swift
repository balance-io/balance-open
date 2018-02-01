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
    private var params: [(key: String, value: String)] {
        switch type {
        case .accounts, .transactions:
            return [
                ("nonce", "\(nonce)")
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
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        
        var components = URLComponents()
        components.queryItems = queryItems
        
        return components
    }

}
