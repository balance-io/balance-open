//
//  BalanceCredentials.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BalanceCredentials: Credentials {
    
    let apiKey: String
    let secretKey: String
    let passphrase: String
    let address: String
    
    init(apiKey: String? = nil, secretKey: String? = nil, passphrase: String? = nil, address: String? = nil) {
        self.apiKey = apiKey ?? ""
        self.secretKey = secretKey ?? ""
        self.passphrase = passphrase ?? ""
        self.address = address ?? ""
    }
    
    init(fields: [Field]) {
        var apiKey = ""
        var secretKey = ""
        var passphrase = ""
        var address = ""
        
        for field in fields {
            switch field.type {
            case .address:
                address = field.value
            case .key:
                apiKey = field.value
            case .secret:
                secretKey = field.value
            case .passphrase:
                passphrase = field.value
            default:
                continue
            }
        }
        
        self.init(apiKey: apiKey, secretKey: secretKey, passphrase: passphrase, address: address)
    }
    
}
