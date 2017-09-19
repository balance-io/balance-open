//
//  EtherscanAccount.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 06/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerAccount {
    let type: AccountType
    let currency: Currency
    
    let address: String
    let available: Double
    let altValue: Double
    let altCurrency: Currency
    let decimals: Int
}

struct EthplorerAccountObject {
    let type: AccountType
    
    let currency: Currency
    
    let address: String
    let ETH: Eth
    let tokens: [Token]
    
    init(dictionary: [String: AnyObject], currencyShortName: String, type: AccountType) throws {
        self.type = type
        self.currency = Currency.rawValue(shortName: "ETH")
    
        self.address = try checkType(dictionary, name: "address")
        
        self.ETH = try Eth.init(dictionary: dictionary["ETH"] as! [String : AnyObject])
        var tokens = [Token]()
        for token in dictionary["tokens"] as! [AnyObject] {
            tokens.append(try Token.init(dictionary: token as! [String : AnyObject]))
        }
        self.tokens = tokens
    }
    
    struct Eth {
        let balance: Double
        let totalIn: Double
        let totalOut: Double
        
        init(dictionary: [String: AnyObject]) throws {
            self.balance = try checkType(dictionary, name: "balance")
            self.totalIn = try checkType(dictionary, name: "totalIn")
            self.totalOut = try checkType(dictionary, name: "totalOut")
        }
    }
    
    struct Token {
        let tokenInfo: TokenInfo
        let balance: Double
        let totalIn: Double
        let totalOut: Double
        
        init (dictionary: [String:AnyObject]) throws {
            self.balance = try checkType(dictionary, name: "balance")
            self.totalIn = try checkType(dictionary, name: "totalIn")
            self.totalOut = try checkType(dictionary, name: "totalOut")
            self.tokenInfo = try TokenInfo.init(dictionary: dictionary["tokenInfo"] as! [String:AnyObject])
        }
    }
    
    struct TokenInfo {
        let address: String
        let name: String
        let decimals: Int
        let symbol: String
        let price: ExchangePrice?
        
        init (dictionary: [String:AnyObject]) throws {
            self.address = try checkType(dictionary, name: "address")
            self.name = try checkType(dictionary, name: "name")
            self.decimals = try checkType(dictionary, name: "decimals")
            self.symbol = try checkType(dictionary, name: "symbol")
            if let _ = dictionary["price"] as? Bool {
                self.price = nil
            } else {
                self.price = try ExchangePrice.init(dictionary: dictionary["price"] as! [String : AnyObject])
            }
        }
    }
    
    //empty info
    struct ExchangePrice {
        let rate: Double
        let currency: Currency
        let diff: Double
        
        init (dictionary: [String:AnyObject]) throws {
            self.rate = try checkType(dictionary, name: "rate")
            self.currency = .common(traditional: .usd)
            self.diff = try checkType(dictionary, name: "diff")
        }
    }
    
    var arrayOfEthplorerAccounts: [EthplorerAccount] {
        var arrayOlder = [EthplorerAccount]()
        let ethAccount = EthplorerAccount.init(type: .wallet, currency: self.currency, address: self.address, available: self.ETH.balance, altValue: 0, altCurrency: Currency.rawValue(shortName: "BTC"), decimals: 8)
        arrayOlder.append(ethAccount)
        for ethplorerObject in self.tokens {
            var altRate: Double = 0
            var altCurrency: Currency = Currency.common(traditional: .usd)
            if let tokenPrice = ethplorerObject.tokenInfo.price {
                altRate = tokenPrice.rate
                altCurrency = tokenPrice.currency
            }
            let balance = ethplorerObject.balance.cientificToEightDecimals(decimals: ethplorerObject.tokenInfo.decimals)
            
            let tokenAccount = EthplorerAccount.init(type: .wallet, currency: Currency.rawValue(shortName: ethplorerObject.tokenInfo.symbol), address: ethplorerObject.tokenInfo.address, available: balance, altValue: altRate, altCurrency: altCurrency, decimals: 8)
            arrayOlder.append(tokenAccount)
        }
        return arrayOlder
    }
}
