//
//  BITTREXAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXAccount2: Codable {
    private var accountInstitutionId: Int = 0    
    private let currency: String
    private let balance: Double
    private let available: Double
    private let pending: Double
    private let cryptoAddress: String?
    private let requested: Bool?
    private let uuid: String?
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case balance = "Balance"
        case available = "Available"
        case pending = "Pending"
        case cryptoAddress = "CryptoAddress"
        case requested = "Requested"
        case uuid = "Uuid"
    }
}

extension BITTREXAccount2: ExchangeAccount {
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
        return .bittrex
    }
    
    var sourceAccountId: String {
        return ""
    }
    
    var name: String {
        return currencyCode
    }
    
    var currencyCode: String {
        // Fixes the special case in Bittrex where they incorrectly use the BCC ticker symbol
        // for BCH (Bitcoin Cash). BCC is already the symbol of Bitconnect so we can't just make
        // them equivalent in the Currency enum and everyone else uses BCH, so we need to save
        // BCC from Bittrex as BCH for it to work correctly.
        return currency == "BCC" ? "BCH" : currency
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
