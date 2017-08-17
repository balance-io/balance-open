//
//  ExchangeProtocols.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente Ferran on 17/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeApi {
    static func authenticate(secret: String, key: String)
    static func authenticate(secret: String, key: String, passphrase: String)
    static func authenticationChallenge()
    //    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock)
    //    static func refreshAccessToken(institution: Institution, completion: @escaping SuccessErrorBlock)
    //    static func updateAccounts(institution: Institution, completion: @escaping SuccessErrorBlock)
    //    static func processAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution)
}
