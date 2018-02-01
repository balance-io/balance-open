//
//  NewPoloniexAccount.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexAccount: ExchangeAccount, Codable {
    var accountType: AccountType = .exchange
    var source: Source = .poloniex
    var institutionId: Int = 0
    var sourceAccountId: String = ""
    var name: String = ""
    var currencyCode: String

    var availableBalance: Int {
        return currentBalance
    }
    
    var altCurrencyCode: String? {
        return altCurrency.code
    }
    var altAvailableBalance: Int? {
        return altCurrentBalance
    }
    
    var currentBalance: Int {
        return available
    }
    
    var altCurrentBalance: Int? {
        return btcValue
    }
    
    // MARK: API specific values
    
    var currency: Currency {
        return Currency.rawValue(currencyCode)
    }
    
    var altCurrency: Currency {
        return Currency.rawValue("BTC")
    }
    
    private var onOrdersString: String
    var onOrders: Int {
        return Double(onOrdersString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var btcValueString: String
    var btcValue: Int {
        return Double(btcValueString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var availableString: String
    var available: Int {
        return Double(availableString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case onOrdersString = "onOrders"
        case btcValueString = "btcValue"
        case availableString = "available"
        case currencyCode = "currency"
    }
}
