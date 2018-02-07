//
//  BITTREXAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXAPI2Action: APIAction {
    
    let nonce: Int64 = Int64(Date().timeIntervalSince1970 * 10000)
    let type: ApiRequestType
    let credentials: Credentials
    
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
            let query = "?" + (self.query ?? "")
            return URL(string: host + apiVersion + methodType + path + query)
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
    
    var transactionURLs: (deposits: URL, withdrawals: URL)? {
        guard case .transactions(_) = type else {
            return nil
        }
        
        let query = "?" + (self.query ?? "")
        
        guard let paths = transactionPaths,
        let depositURL = URL(string: host + apiVersion + methodType + paths.deposits + query),
            let withdrawalURL = URL(string: host + apiVersion + methodType + paths.withdrawals + query) else {
                return nil
        }
        
        return (depositURL, withdrawalURL)
    }
    
    var transactionPaths: (deposits: String, withdrawals: String)? {
        guard case .transactions(_) = type else {
            return nil
        }
        
        return ("getdeposithistory", "getwithdrawalhistory")
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
