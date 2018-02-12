//
//  GDAXAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct GDAXAccount2: Codable {
    private var accountInstitutionId: Int = 0
    private var accountSource: Source = .gdax
    private let identifier: String
    private let profileID: String
    private let currencyString: String
    private let availableString: String
    private let balanceString: String
    private let heldFunds: String
    
    private var currency: Currency {
        return Currency.rawValue(currencyString)
    }
    
    private var balance: Double {
        return Double(balanceString) ?? 0
    }
    private var available: Double {
        return Double(availableString) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case profileID = "profile_id"
        case currencyString = "currency"
        case availableString = "available"
        case balanceString = "balance"
        case heldFunds = "hold"
    }
}

extension GDAXAccount2: ExchangeAccount {
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
        get {
            return accountSource
        }
        set {
            accountSource = newValue
        }
    }
    
    var sourceAccountId: String {
        return identifier
    }
    
    var name: String {
        return currency.code
    }
    
    var currencyCode: String {
        return currency.code
    }
    
    var currentBalance: Int {
        return balance.integerFixedCryptoDecimals()
    }
    
    var availableBalance: Int {
        return available.integerFixedCryptoDecimals()
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
