//
//  KrakenAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/7/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KrakenAccount2 {
    private let assetCode: String
    private let balance: Double
    private var accountInstitutionId: Int = 0
    
    // NOTE: Kraken standardizes all of their currency codes to 4 characters for some reason
    // so for example LTC is XLTC, USD is ZUSD, but USDT is just USDT. So we need to remove
    // the trailing characters. It appears that X is for crypto and Z is for fiat.
    
    // TODO: Right now, we're safe just removing trailing Z and X characters. However, in the
    // future, if there is a 4 letter symbol for a currency and it starts with X or Z, we will
    // run into issues. Thankfully they use XZEC for ZCASH tokens.
    private var currency: Currency {
        var currencyCode = assetCode
        if assetCode.count == 4 && (assetCode.hasPrefix("Z") || assetCode.hasPrefix("X")) {
            currencyCode = assetCode.substring(from: 1)
        }
        return Currency.rawValue(currencyCode)
    }
    
    init(currency: String, balance: String) {
        self.balance = Double(balance) ?? 0
        self.assetCode = currency
    }
    
}

extension KrakenAccount2: ExchangeAccount {
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
        return .kraken
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

