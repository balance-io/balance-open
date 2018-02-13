//
//  BinanceAccount.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BinanceAccounts: Codable {
    
    private let makerCommission: Int
    private let takerCommission: Int
    private let buyerCommission: Int
    private let sellerCommission: Int
    private let canTrade: Bool
    private let canWithdraw: Bool
    private let canDeposit: Bool
    private let updateTime: Int
    let balances: [BinanceAccount]
    
}

struct BinanceAccount: Codable {
    
    private var currency: Currency {
        return Currency.rawValue(asset)
    }
    
    let asset: String
    let free: String
    let locked: String
    let source: Source = .binance
    var institutionId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case asset
        case free
        case locked
    }
    
}

extension  BinanceAccount: ExchangeAccount {
    
    var currencyCode: String {
        return currency.code
    }
    
    var accountType: AccountType {
        return .exchange
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var name: String {
        return currency.name
    }
    
    var currentBalance: Int {
        guard let balance = Double(free) else {
            return 0
        }
        
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
