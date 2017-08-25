//
//  ExchangeProtocols.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente Ferran on 17/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeApi {
    //    func authenticate(secret: String, key: String)
    //    func authenticate(secret: String, key: String, passphrase: String)
    func authenticationChallenge(loginStrings: [Field], closeBlock: @escaping (_ success: Bool) -> Void)
}

