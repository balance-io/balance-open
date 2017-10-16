//
//  PoloniexAccount.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente on 28/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct PoloniexAccount {
    let type: AccountType
    
    let currency: Currency
    let available: Decimal
    let onOrders: Decimal
    let btcValue: Decimal
    
    init(dictionary: [String: Any], currencyShortName: String, type: AccountType) throws {
        self.type = type
        self.currency = Currency.rawValue(currencyShortName)
        let availableAmount: String = try checkType(dictionary["available"], name: "available")
        let availableDecimal = NumberUtils.decimalFormatter.number(from: availableAmount)?.decimalValue
        self.available = try checkType(availableDecimal, name: "availableDecimal")
        
        let onOrdersAmount: String = try checkType(dictionary["onOrders"], name: "onOrders")
        let onOrdersdecimal = NumberUtils.decimalFormatter.number(from: onOrdersAmount)?.decimalValue
        self.onOrders = try checkType(onOrdersdecimal, name: "onOrdersdecimal")
        
        let btcValueAmount: String = try checkType(dictionary["btcValue"], name: "btcValue")
        let btcValueDecimal = NumberUtils.decimalFormatter.number(from: btcValueAmount)?.decimalValue
        self.btcValue = try checkType(btcValueDecimal, name: "btcValueDecimal")
    }

}
