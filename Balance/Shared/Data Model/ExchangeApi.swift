//
//  ExchangeProtocols.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente Ferran on 17/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ExchangeApi {
    //    func authenticate(secret: String, key: String)
    //    func authenticate(secret: String, key: String, passphrase: String)
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (_ success: Bool, _ error: Error?, _ institution: Institution?) -> Void)
}

extension Source {
    var exchangeApi: ExchangeApi {
        switch self {
        case .coinbase:  return CoinbaseApi()
        case .gdax:      return GDAXAPIClient(server: .production)
        case .poloniex:  return PoloniexApi()
        case .bitfinex:  return BitfinexAPIClient()
        case .kraken:    return KrakenAPIClient()
        case .ethplorer: return EthplorerApi()
        }
    }
}
