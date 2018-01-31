//
//  ApiInstitution.swift
//  Balance
//
//  Created by Benjamin Baron on 8/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ApiInstitution {
    var source: Source { get }
    var sourceInstitutionId: String { get }
    
    var currencyCode: String { get }
    var usernameLabel: String { get }
    var passwordLabel: String { get }
    
    var name: String { get}
    var products: [String] { get }
    
    var type: String { get }
    var url: String? { get }
    
    var fields: [Field] { get }
}

struct Field {
    var name: String
    var type: FieldType
    var value: String?
    
    var testValue: String? {
        switch type {
        case .key:
            return ""
        case .secret:
            return ""
        case .address:
            return ""
        default:
            return ""
        }
    }
}

enum FieldType: String {
    case key        = "key"
    case secret     = "secret"
    case passphrase = "passphrase"
    case name       = "name"
    case address    = "address"
}

extension Source {
    var apiInstitution: ApiInstitution {
        switch self {
        case .coinbase:     return CoinbaseInstitution()
        case .gdax:         return GDAXAPIClient.gdaxInstitution
        case .poloniex:     return PoloniexInstitution()
        case .bitfinex:     return BitfinexAPIClient.institution
        case .kraken:       return KrakenAPIClient.institution
        case .ethplorer:    return EthplorerInstitution()
        case .bittrex:      return BITTREXInstitution()
        case .blockchain:   return BtcInstitution()
        }
    }
}
