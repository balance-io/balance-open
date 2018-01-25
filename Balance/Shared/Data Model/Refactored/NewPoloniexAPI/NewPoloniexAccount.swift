//
//  NewPoloniexAccount.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexAccount: ExchangeAccount, Codable {

    var institutionId: Int = 0
    var source: Source = .poloniex
    var sourceAccountId: String = ""
    var name: String = ""
    var currencyCode: String = ""
    var currentBalance: Int = 0
    var availableBalance: Int = 0
    var altCurrencyCode: String? = ""
    var altCurrentBalance: Int? = 0
    var altAvailableBalance: Int? = 0
    
    // API specific values
    private var onOrdersString: String
    var onOrders: Int {
        return Double(onOrdersString)?
            .integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var btcValueString: String
    var btcValue: Int {
        return Double(btcValueString)?
            .integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    private var availableString: String
    var available: Int {
        return Double(availableString)?
            .integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case onOrdersString = "onOrders"
        case btcValueString = "btcValue"
        case availableString = "available"
    }
}


