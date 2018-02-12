//
//  BitfinexAccount2.swift
//  BalancemacOS
//
//  Created by Felipe Rolvar on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BitfinexAccount2 {
    private var accountInstitutionId: Int = 0
    private var accountSource: Source = .bitfinex
    private let type: String
    private let currency: Currency
    private let balance: Double
    private let unsettledInterest: Double
    private let available: Double?
    
    init(type: String, currency: Currency, balance: Double, unsettledInterest: Double, available: Double?) {
        self.type = type
        self.currency = currency
        self.balance = balance
        self.unsettledInterest = unsettledInterest
        self.available = available
    }
}

extension BitfinexAccount2: ExchangeAccount {
    var accountType: AccountType {
        return AccountType(plaidString: type)
    }
    
    var institutionId: Int {
        get {
            return accountInstitutionId
        }
        set {
            accountInstitutionId = newValue
        }
    }
    
    var source: Source {
        get {
            return accountSource
        }
        set {
            accountSource = newValue
        }
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var name: String {
        return currency.name
    }
    
    var currencyCode: String {
        return currency.code
    }
    
    var currentBalance: Int {
        return balance.integerValueWith(decimals: currency.decimals)
    }
    
    var availableBalance: Int {
        return available?.integerValueWith(decimals: currency.decimals) ?? 0
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

