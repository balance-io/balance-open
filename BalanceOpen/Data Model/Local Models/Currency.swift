//
//  Currency.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum Currency: String {
    // Traditional
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    
    // Crypto
    case btc = "BTC"
    case ltc = "LTC"
    case eth = "ETH"
    
    // TODO: Don't hard code decimals for crypto
    var decimals: Int {
        switch self {
        case .btc, .ltc, .eth: return 8
        default: return 2
        }
    }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .btc: return "Ƀ"
        case .eth: return "Ξ"
        default: return self.rawValue + " "
        }
    }
}
