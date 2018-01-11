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
            return "3V2042Q9-SC11NFCR-B3SM7RIQ-COCI9C83"
        case .secret:
            return "9204c089f5fcdc853d5aef92589fbe396f9de3dc70aaa22e9ce1f9a4f441022c0bcde51dc5b18eecf25508c08bb841a18be91e222da7fba5ab46f1b1dc2f21db"
        default:
            return nil
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
        case .coinbase:  return CoinbaseInstitution()
        case .gdax:      return GDAXAPIClient.gdaxInstitution
        case .poloniex:  return PoloniexInstitution()
        case .bitfinex:  return BitfinexAPIClient.institution
        case .kraken:    return KrakenAPIClient.institution
        case .ethplorer: return EthplorerInstitution()
        }
    }
}
