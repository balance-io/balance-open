//
//  Source.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

/// This data is duplicated in the sources database table for use in joins if needed
enum Source: Int, CustomStringConvertible {
    case plaid              = 1
    case coinbase           = 2
    case poloniex           = 3
    case gdax               = 4
    case bitfinex           = 5
    case cryptoExchange     = 6
    case wallet             = 7
    
    var description: String {
        switch self {
        case .plaid:            return "Plaid"
        case .coinbase:         return "Coinbase"
        case .poloniex:         return "Poloniex"
        case .gdax:             return "GDAX"
        case .bitfinex:         return "Bitfinex"
        case .cryptoExchange:   return "Crypto Exchange"
        case .wallet:           return "Wallet"
        }
    }
}
