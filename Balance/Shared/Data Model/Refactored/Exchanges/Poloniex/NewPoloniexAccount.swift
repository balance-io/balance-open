//
//  NewPoloniexAccount.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexAccount: Codable {
    private var accountInstitution: Int = 0
    private var currencyString: String
    
    var currency: Currency {
        return Currency.rawValue(currencyCode)
    }
    
    var altCurrency: Currency {
        return Currency.rawValue("BTC")
    }
    
    private var onOrdersString: String
    private var onOrders: Int {
        return Double(onOrdersString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var btcValueString: String
    private var btcValue: Int {
        return Double(btcValueString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var availableString: String
    private var available: Int {
        return Double(availableString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case onOrdersString = "onOrders"
        case btcValueString = "btcValue"
        case availableString = "available"
        case currencyString = "currency"
    }
}

//MARK: Protocol

extension NewPoloniexAccount: ExchangeAccount {
    var accountType: AccountType {
        return .exchange
    }
    
    var institutionId: Int {
        get {
            return accountInstitution
        }
        set {
            accountInstitution = newValue
        }
    }
    
    var source: Source {
        return .poloniex
    }
    
    var sourceAccountId: String {
        return currencyCode
    }
    
    var name: String {
        return currencyCode
    }
    
    var currencyCode: String {
        return currencyString
    }
    
    var currentBalance: Int {
        return available
    }
    
    var availableBalance: Int {
        return available
    }
    
    var altCurrencyCode: String? {
        return altCurrency.code
    }
    
    var altCurrentBalance: Int? {
        return btcValue
    }
    
    var altAvailableBalance: Int? {
        return altCurrentBalance
    }
}
