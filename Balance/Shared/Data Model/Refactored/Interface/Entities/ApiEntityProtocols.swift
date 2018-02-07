//
//  ApiEntityProtocols.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/24/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public protocol Credentials {
    var apiKey: String { get }
    var secretKey: String { get }
    var passphrase: String { get }
    var address: String { get }
    var name: String { get }
}

protocol OAUTHCredentials: Credentials {
    var accessToken: String { get }
    var refreshToken: String { get }
    var apiScope: String { get }
    var expiresIn: Double { get }
    var expireDate: Date { get } 
}

public protocol ExchangeInstitution {
    var source: Source { get }
    var name: String { get}
    var fields: [Field] { get }
}

public protocol ExchangeAccount {
    var accountType: AccountType { get }
    var institutionId: Int { get set }
    var source: Source { get set }
    var sourceAccountId: String { get }
    var name: String { get }
    var currencyCode: String { get }
    var currentBalance: Int { get }
    var availableBalance: Int { get }
    var altCurrencyCode: String? { get }
    var altCurrentBalance: Int? { get }
    var altAvailableBalance: Int? { get }
}

public protocol ExchangeTransaction {
    var type: String { get set }
    var institutionId: Int { get set }
    var source: Source { get }
    var sourceInstitutionId: String { get set }
    var sourceAccountId: String { get }
    var sourceTransactionId: String { get }
    var name: String { get }
    var date: Date { get } // UTC
    var currencyCode: String { get }
    var amount: Int { get }
}
