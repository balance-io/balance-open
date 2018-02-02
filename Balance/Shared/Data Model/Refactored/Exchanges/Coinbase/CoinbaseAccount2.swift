//
//  CoinbaseAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/2/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CoinbaseAccount2: Codable {
    
    private var accountInstitution: Int = 0
    private var accountSource: Source = .poloniex
    private let id: String
    private let accountName: String
    private let primary: Bool
    private let type: String
    private let currencyString: String
    private let amount: String
    private let nativeBalanceDict: NativeBalanceDict

    private var currency: Currency {
        return Currency.rawValue(currencyString)
    }
    
    private var altCurrency: Currency {
        return Currency.rawValue(nativeBalanceDict.currency)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountName = "name"
        case primary
        case type
        case currencyString = "currency"
        case amount
        case nativeBalanceDict = "native_balance"
    }
}

struct NativeBalanceDict: Codable {
    let currency: String
    let amount: String
}

extension CoinbaseAccount2: ExchangeAccount {
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
        get {
            return accountSource
        }
        set {
            accountSource = newValue
        }
    }
    
    var sourceAccountId: String {
        return id
    }
    
    var name: String {
        return accountName
    }
    
    var currencyCode: String {
        return currency.code
    }
    
    var currentBalance: Int {
       return Double(amount)?.integerValueWith(decimals: currency.decimals) ?? 0
    }
    
    var availableBalance: Int {
        return currentBalance
    }
    
    var altCurrencyCode: String? {
        return altCurrency.code
    }
    
    var altCurrentBalance: Int? {
        return Double(nativeBalanceDict.amount)?.integerValueWith(decimals: altCurrency.decimals) ?? 0
    }
    
    var altAvailableBalance: Int? {
        return altCurrentBalance
    }
    
}
