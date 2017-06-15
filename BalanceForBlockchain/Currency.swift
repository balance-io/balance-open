//
//  Currency.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum Currency: String {
    // Fiat
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    
    // Crypto
    case BTC = "BTC"
    case LTC = "LTC"
    case ETH = "ETH"
}
