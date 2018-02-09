//
//  BITTREXAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXAPI2Action: APIAction {
    
    let type: ApiRequestType
    let credentials: Credentials
    let internalNonce: Int64 = Int64(Date().timeIntervalSince1970 * 10000)
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
}

extension BITTREXAPI2Action {
    
    var host: String {
        return "https://bittrex.com/"
    }
    
    var url: URL? {
        switch type {
        case .accounts:
            return URL(string: baseURL + path + validQuery)
        case .transactions(_):
            return nil
        }
    }
    
    var components: URLComponents? {
        return getBasicURLComponents(from: params)
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "getbalances"
        case .transactions(_):
            return ""
        }
    }
    
    var nonce: Int64 {
        return internalNonce
    }
    
}

private extension BITTREXAPI2Action {
    
    var params: [String: String] {
        return [
            "apikey" : credentials.apiKey,
            "nonce" : String(nonce)
        ]
    }
    
    var apiVersion: String {
        return "api/v1.1/"
    }
    
    var methodType: String {
        switch type {
        case .accounts, .transactions(_):
            return "account/"
        }
    }
    
}

//MARK: Transaction variables
extension BITTREXAPI2Action {
    
    private var baseURL: String {
        return host + apiVersion + methodType
    }

    private var validQuery: String {
        guard let validQuery = self.query else {
            return ""
        }
        
        return "?" + validQuery
    }
    
    private var depositPath: String {
        return "getdeposithistory"
    }
    
    private var withdrawalPath: String {
        return "getwithdrawalhistory"
    }
    
    var depositTransactionURL: URL? {
        return URL(string: baseURL + depositPath + validQuery)
    }
    
    var withdrawalTransactionURL: URL? {
        return URL(string: baseURL + withdrawalPath + validQuery)
    }
    
}
