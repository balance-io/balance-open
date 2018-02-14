//
//  KucoinAccount.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/14/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KucoinAccounts: Decodable {
    private let data: [KucoinAccount]
    
    var accounts: [ExchangeAccount] {
        return data
    }
}

struct KucoinAccount: Decodable {
    
    let coinType: String
    let balance: Double
    let freezeBalance: Double
    
    var institutionId: Int = -1
    var source: Source = .kucoin
    
    private var currency: Currency {
        return Currency.rawValue(coinType)
    }
    
    enum CodingKeys: String, CodingKey {
        case coinType
        case balance
        case freezeBalance
    }
    
}


extension KucoinAccount: ExchangeAccount {

    var currencyCode: String {
        return currency.code
    }

    var accountType: AccountType {
        return .exchange
    }

    var sourceAccountId: String {
        return currency.code
    }

    var name: String {
        return currency.name
    }

    var currentBalance: Int {
        return balance.integerFixedCryptoDecimals()
    }

    var availableBalance: Int {
        return currentBalance
    }

    var altCurrencyCode: String? {
        return nil
    }

    var altCurrentBalance: Int? {
        return nil
    }

    var altAvailableBalance: Int? {
        return nil
    }

}


