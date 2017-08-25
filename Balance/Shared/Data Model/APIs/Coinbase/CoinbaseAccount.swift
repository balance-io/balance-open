//
//  CoinbaseAccount.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/12/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CoinbaseAccount {
    let id: String
    let name: String
    let primary: Bool
    let type: String
    
    let currency: String
    let balance: Decimal
    let nativeCurrency: String
    let nativeBalance: Decimal
    
//    let createdAt: Date
//    let updatedAt: Date
    
    init(account: [String: AnyObject]) throws {
        self.id = try checkType(account, name: "id")
        self.name = try checkType(account, name: "name")
        self.primary = try checkType(account, name: "primary")
        self.type = try checkType(account, name: "type")
        
        let balanceDict: [String: AnyObject] = try checkType(account, name: "balance")
        self.currency = try checkType(balanceDict, name: "currency")
        let balanceAmount: String = try checkType(balanceDict, name: "amount")
        let balanceAmountDecimal = NumberUtils.decimalFormatter.number(from: balanceAmount)?.decimalValue
        self.balance = try checkType(balanceAmountDecimal, name: "balanceAmountDecimal")
        
        let nativeBalanceDict: [String: AnyObject] = try checkType(account, name: "native_balance")
        self.nativeCurrency = try checkType(nativeBalanceDict, name: "currency")
        let nativeBalanceAmount: String = try checkType(nativeBalanceDict, name: "amount")
        let nativeBalanceAmountDecimal = NumberUtils.decimalFormatter.number(from: nativeBalanceAmount)?.decimalValue
        self.nativeBalance = try checkType(nativeBalanceAmountDecimal, name: "balanceAmountDecimal")
        
        // TODO: Finish this
//        let createdAtString: String = try checkType(account, name: "created_at")
//        self.createdAt = jsonDateFormatter.date(from: createdAtString) ?? throw "
//        self.updatedAt = try checkType(account, name: "updated_at")
    }
}
