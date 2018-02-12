//
//  HitBTCAccount.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct HitBTCAccount: Codable {
    
    private let balance: String
    private var currency: Currency {
        return Currency.rawValue(currencyCode)
    }
    
    let currencyCode: String
    var institutionId: Int = -1
    var source: Source = .hitbtc
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency"
        case balance = "available"
    }
    
}

extension HitBTCAccount: ExchangeAccount {
    
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
        guard let balance = Double(balance) else {
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
