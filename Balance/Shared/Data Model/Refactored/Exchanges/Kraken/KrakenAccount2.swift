//
//  KrakenAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/7/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KrakenAccount2 {
    private let currency: Currency
    private let balance: Double
    private var accountInstitutionId: Int = 0
    private var accountSource: Source = .kraken
    
    init(currency: String, balance: String) {
        self.balance = Double(balance) ?? 0
        self.currency = Currency.rawValue(currency)
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

