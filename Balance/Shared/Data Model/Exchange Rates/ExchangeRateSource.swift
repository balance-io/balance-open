//
//  ExchangeRateSource.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 9/28/17.
//

import Foundation

public enum ExchangeRateSource: Int {
    // Crypto
    case average         = 0
    case coinbaseGdax    = 1
    case poloniex        = 2
    case bitfinex        = 3
    case kraken          = 4
    case kucoin          = 5
    case hitbtc          = 6
    case binance         = 7
    case coinbaseGdaxEur = 8
    case coinbaseGdaxGbp = 9
    case bittrex         = 10
    
    // Fiat
    case fixer         = 10001
    case currencylayer = 10002
    
    public var source: Int {
        switch self {
        case .coinbaseGdax, .coinbaseGdaxEur, .coinbaseGdaxGbp:
            return 1
        default:
            return rawValue
        }
    }
    
    // These are the currencies that we try to convert as an in between step
    public static var mainCurrencies: [Currency] {
        return [.btc, .eth, .usd]
    }
    
    public static var allCrypto: [ExchangeRateSource] {
        return [.average, .coinbaseGdax, .poloniex, .bitfinex, .kraken, .kucoin, .hitbtc, .binance, .bittrex]
    }
    
    public static var allFiat: [ExchangeRateSource] {
        return [.fixer, .currencylayer]
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
        case .ethplorer:        return .average
        case .bittrex:          return .bittrex
        }
    }
}
