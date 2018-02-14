//
//  CEXAccount.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/14/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CEXAccount: Codable {
    private var accountInstitutionId: Int = 0
    private let timestamp: String
    private let currencyString: String
    private let availableString: String

    private var date: Date {
        return Date(timeIntervalSince1970: Double(timestamp) ?? 0)
    }
    
    private var currency: Currency {
        return Currency.rawValue(currencyString)
    }
    
    private var available: Double {
        return Double(availableString) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case currencyString = "currency"
        case availableString = "available"
    }
}

extension CEXAccount: ExchangeAccount {
    var accountType: AccountType {
        return .exchange
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
        return .cex
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
        return currency.isFiat ? available.integerFixedFiatDecimals() : available.integerFixedCryptoDecimals()
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
