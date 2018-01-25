//
//  APiCredentialsProtocol.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/24/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public struct BalanceApiCredentials: Credentials {
    public var apiKey: String
    public var secretKey: String
    public var passphrase: String
}
