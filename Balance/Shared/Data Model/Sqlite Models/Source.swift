//
//  Source.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

/// This data is duplicated in the sources database table for use in joins if needed
enum Source: Int, CustomStringConvertible {
//    case plaid     = 1 // Disabled for now to allow for exhaustive switch statements
    case coinbase  = 2
    case poloniex  = 3
    case gdax      = 4
    case bitfinex  = 5
    case kraken    = 6
    case ethplorer = 7
    case bittrex = 8
    
    var description: String {
        switch self {
//        case .plaid:     return "Plaid"
        case .coinbase:  return "Coinbase"
        case .poloniex:  return "Poloniex"
        case .gdax:      return "GDAX"
        case .bitfinex:  return "Bitfinex"
        case .kraken:    return "Kraken"
        case .ethplorer: return "Ethereum Wallet"
        case .bittrex:   return "BITTREX"
        }
    }
    
    var color: PXColor {
        switch self {
        case .coinbase:  return PXColor(hexString: "#0667D0")!
        case .poloniex:  return PXColor(hexString: "#086166")!
        case .gdax:      return PXColor(hexString: "#212D3D")!
        case .bitfinex:  return PXColor(hexString: "#58AD03")!
        case .kraken:    return PXColor(hexString: "#4F6E89")!
        case .ethplorer: return PXColor(hexString: "#333D4E")!
        case .bittrex:   return PXColor(hexString: "#29333D")!
        }
    }
    
    var helpUrl: URL {
        switch self {
        case .coinbase:  return URL(string: "https://coinbase.com")!
        case .poloniex:  return URL(string: "https://github.com/balancemymoney/balance-open/wiki/Poloniex-Guide")!
        case .gdax:      return URL(string: "https://github.com/balancemymoney/balance-open/wiki/Gdax-Manual")!
        case .bitfinex:  return URL(string: "https://github.com/balancemymoney/balance-open/wiki/Bitfinex-Guide")!
        case .kraken:    return URL(string: "https://github.com/balancemymoney/balance-open/wiki/Kraken-Login-Manual")!
        case .ethplorer: return URL(string: "https://etherscanio.freshdesk.com/support/solutions/articles/16000046111-what-is-an-ethereum-address-and-how-to-do-i-get-one-")!
        }
    }
}
