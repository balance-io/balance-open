//
//  EthplorerAPIAction.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/1/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerAPI2Action: APIAction {
    
    let credentials: Credentials
    let type: ApiRequestType
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension EthplorerAPI2Action {
    
    var host: String {
        return "https://api.ethplorer.io/"
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "getAddressInfo/\(credentials.address)"
        case .transactions(_):
            return ""
        }
    }
    
    private var params: [String: String] {
        return [
            "apiKey": ethploreToken
        ]
    }
    
    private var ethploreToken: String {
        return "freekey"
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
    var nonce: Int64 {
        return 0
    }
    
    var components: URLComponents {
        return getBasicURLComponents(from: params)
    }
    
}
