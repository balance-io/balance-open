//
//  ExchangeRateSource.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 9/28/17.
//

import Foundation

public enum ExchangeRateSource: Int {
    // Crypto
    case coinbaseGdax = 1
    case poloniex     = 2
    case bitfinex     = 3
    case kraken       = 4
    case kucoin       = 5
    case hitbtc       = 6
    case binance      = 7
    
    // Fiat
    case fixer        = 10001
    
    // These are the currencies that values are stored in for this exchange (i.e. Poloniex only has BTC and ETC, but not fiat currencies)
    public var mainCurrencies: [Currency] {
        switch self {
            //        case .poloniex: return [.btc, .eth]
        //        case .kraken: return [.usd, .btc]
        default: return [.btc, .eth, .usd]
        }
    }
    
    public static var allCrypto: [ExchangeRateSource] {
        return [.coinbaseGdax, .poloniex, .bitfinex, .kraken, .kucoin, .hitbtc, .binance]
    }
    
    public static var allFiat: [ExchangeRateSource] {
        return [.fixer]
    }
    
    public static var all: [ExchangeRateSource] {
        return allCrypto + allFiat
    }
}

extension Source {
    public var exchangeRateSource: ExchangeRateSource {
        switch self {
        //case .plaid:    return "Plaid"
        case .coinbase, .gdax:  return .coinbaseGdax
        case .poloniex:         return .poloniex
        case .bitfinex:         return .bitfinex
        case .kraken:           return .kraken
        case .ethplorer:        return .hitbtc
        }
    }
}
