//
//  ExchangeProtocols.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente Ferran on 17/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeApi {
    func authenticate(secret: String, key: String)
    func authenticate(secret: String, key: String, passphrase: String)
    func authenticationChallenge(loginStrings: [OpenField], closeBlock: @escaping (_ success: Bool) -> Void)
    //    static func handleAuthenticationCallback(state: String, code: String, completion: @escaping SuccessErrorBlock)
    //    static func refreshAccessToken(institution: Institution, completion: @escaping SuccessErrorBlock)
    //    static func updateAccounts(institution: Institution, completion: @escaping SuccessErrorBlock)
    //    static func processAccounts(_ coinbaseAccounts: [CoinbaseAccount], institution: Institution)
}
