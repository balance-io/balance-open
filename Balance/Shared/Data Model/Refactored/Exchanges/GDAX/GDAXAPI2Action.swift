//
//  GDAXAPI2Action.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/5/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct GDAXAPI2Action: APIAction {
    
    let nonce: Int64 = Int64(Date().timeIntervalSince1970)
    let type: ApiRequestType
    let credentials: Credentials
    private var environment: ServerEnvironment = .production
    
    init(type: ApiRequestType, credentials: Credentials) {
        self.type = type
        self.credentials = credentials
    }
    
    init(environment: ServerEnvironment, type: ApiRequestType, credentials: Credentials) {
        self.init(type: type, credentials: credentials)
        self.environment = environment
    }
    
}

extension GDAXAPI2Action {
    
    enum TransactionInputDataType: String {
        case accountId
        case currencyCode
    }
    
    var host: String {
        switch environment {
        case .sandbox:
            return "https://api-public.sandbox.gdax.com"
        case .production:
            return "https://api.gdax.com"
        }
    }
    
    var components: URLComponents? {
        return nil
    }
    
    var path: String {
        switch type {
        case .accounts:
            return "/accounts"
        case .transactions(let dict):
            guard let dict = dict as? [String: Any],
            let accountId = dict[TransactionInputDataType.accountId.rawValue] as? String else {
                return ""
            }
            
            return "/accounts/\(accountId)/ledger"
        }
    }
    
    var url: URL? {
        return URL(string: host + path)
    }
    
}
