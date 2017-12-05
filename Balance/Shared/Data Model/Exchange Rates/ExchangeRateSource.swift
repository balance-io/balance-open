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
    
    public var url: URL {
        switch self {
        // Crypto
        case .coinbaseGdax:
            return URL(string: "https://api.coinbase.com/v2/prices/usd/spot")!
        case .poloniex:
            return URL(string: "https://poloniex.com/public?command=returnTicker")!
        case .bitfinex:
            // TODO: Call https://api.bitfinex.com/v1/symbols API to get the current symbols\instead of updating manually
            return URL(string: "https://api.bitfinex.com/v2/tickers?symbols=tBTCUSD,tETHUSD,tLTCUSD,tOMGUSD,tBCHUSD,tIOTAUSD,tETCUSD,tXMRUSD,tEOSUSD,tDASHUSD,tNEOUSD,tZECUSD,tXRPUSD,tSANUSD,tBCCUSD,tRRTUSD,tBCUUSD")!
        case .kraken:
            // TODO: Call https://api.kraken.com/0/public/AssetPairs API to get the current asset pairs instead of updating manually
            return URL(string: "https://api.kraken.com/0/public/Ticker?pair=BCHUSD,DASHUSD,XETCZUSD,XETHZUSD,XLTCZUSD,XXBTZUSD,XXMRZUSD,XXRPZUSD,XZECZUSD,EOSXBT,GNOXBT,XICNXXBT,XMLNXXBT,XREPXXBT,XXDGXXBT,XXLMXXBT,XXMRXXBT")!
        case .kucoin:
            return URL(string: "https://api.kucoin.com/v1/open/tick")!
        case .hitbtc:
            return URL(string: "https://api.hitbtc.com/api/2/public/ticker")!
        case .binance:
            return URL(string: "https://api.binance.com/api/v1/ticker/allPrices")!
            
        // Fiat
        case .fixer:
            return URL(string: "http://api.fixer.io/latest?base=USD")!
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .coinbaseGdax:
            return ["CB-VERSION": "2017-05-19"]
        default:
            return [:]
        }
    }
    
    public var httpMethod: String {
        return "GET"
    }
    
    public var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return request
    }
    
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
