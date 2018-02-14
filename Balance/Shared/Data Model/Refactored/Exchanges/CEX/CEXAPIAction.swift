//
//  CEXAPIAction.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/13/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CEXAPIAction {
    var type: ApiRequestType
    var credentials: Credentials
    let nonce = Int64(Date().timeIntervalSince1970 * 10000)
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
}

extension CEXAPIAction: APIAction {
    
    var host: String {
        return "https://cex.io/api/"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "balance/"
        case .transactions(_):
            return ""
        }
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
    
    private var params: [(key: String, value: String)] {
        switch type {
        case .accounts, .transactions:
            return [
                ("key", "\(credentials.apiKey)"),
                ("nonce", "\(nonce)")
            ]
        }
    }
}
