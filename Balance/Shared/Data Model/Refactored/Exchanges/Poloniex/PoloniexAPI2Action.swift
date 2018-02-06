//
//  PoloniexAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/24/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct PoloniexApiAction {
    
    let type: ApiRequestType
    let credentials: Credentials
    let nonce = Int64(Date().timeIntervalSince1970 * 10000)
    private let end = Date().timeIntervalSince1970
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
}

extension PoloniexApiAction: APIAction {
    private var params: [(key: String, value: String)] {
        switch type {
        case .accounts:
            return [
                ("command", "returnCompleteBalances"),
                ("nonce", "\(nonce)")
            ]
        case .transactions:
            return [
                ("command", "returnDepositsWithdrawals"),
                ("start", "0"),
                ("end", "\(end)"),
                ("nonce", "\(nonce)")
            ]
        }
    }
    
    var host: String {
        return "https://poloniex.com/"
    }
    
    var path: String {
        return "tradingApi"
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
    var components: URLComponents? {
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        
        var components = URLComponents()
        components.queryItems = queryItems
        
        return components
    }

}
