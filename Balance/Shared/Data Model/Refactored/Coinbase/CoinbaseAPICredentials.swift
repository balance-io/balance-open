//
//  CoinbaseAPICredentials.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/30/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CoinbaseAutentication: Decodable, OAUTHCredentials {
    
    let tokenType: String
    let expiresIn: Double
    let accessToken: String
    let refreshToken: String
    let code: Double
    let apiScope: String
    
    init(tokenType: String = "", expiresIn: Double = 0, accessToken: String = "", refreshToken: String, code: Double, apiScope: String) {
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.code = code
        self.apiScope = apiScope
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CoinbaseAuthenticationKey.self)
        let tokenType: String = try container.decode(String.self, forKey: .tokenType)
        let expiresIn: Double = try container.decode(Double.self, forKey: .expiresIn)
        let accessToken: String = try container.decode(String.self, forKey: .accessToken)
        let refreshToken: String = try container.decode(String.self, forKey: .refreshToken)
        let code: Double = try container.decode(Double.self, forKey: .code)
        let apiScope: String = try container.decode(String.self, forKey: .apiScope)
        
        self.init(tokenType: tokenType, expiresIn: expiresIn, accessToken: accessToken, refreshToken: refreshToken, code: code, apiScope: apiScope)
    }
    
}
