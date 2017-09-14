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
    let available: Decimal
    let altValue: Decimal
    let altCurrency: Currency
}

struct EthplorerAccountObject {
    let type: AccountType
    
    let currency: Currency
    
    let address: String
    let ETH: Eth
    let tokenInfo: String
    let tokens: [Token]
    
    init(dictionary: [String: AnyObject], currencyShortName: String, type: AccountType) throws {
        self.type = type
        self.currency = Currency.rawValue(shortName: "ETH")
    
        self.tokenInfo = try checkType(dictionary, name: "tokenInfo")
        self.address = try checkType(dictionary, name: "address")
        
        self.ETH = try Eth.init(dictionary: dictionary["ETH"] as! [String : AnyObject])
        var tokens = [Token]()
        for token in dictionary["tokens"] as! [AnyObject] {
            tokens.append(try Token.init(dictionary: token as! [String : AnyObject]))
        }
        self.tokens = tokens
    }
    
    struct Eth {
        let balance: Decimal
        let totalIn: Decimal
        let totalOut: Decimal
        
        init(dictionary: [String: AnyObject]) throws {
            let balanceRaw: String = try checkType(dictionary, name: "balance")
            let balanceDecimal = NumberUtils.decimalFormatter.number(from: balanceRaw)?.decimalValue
            self.balance = try checkType(balanceDecimal, name: "balanceDecimal")
            
            let totalInRaw: String = try checkType(dictionary, name: "totalIn")
            let totalInDecimal = NumberUtils.decimalFormatter.number(from: totalInRaw)?.decimalValue
            self.totalIn = try checkType(totalInDecimal, name: "totalInDecimal")
            
            let totalOutRaw: String = try checkType(dictionary, name: "totalOut")
            let totalOutDecimal = NumberUtils.decimalFormatter.number(from: totalOutRaw)?.decimalValue
            self.totalOut = try checkType(totalOutDecimal, name: "totalOutDecimal")
        }
    }
    
    struct Token {
        let tokenInfo: TokenInfo
        let balance: Decimal
        let totalIn: Decimal
        let totalOut: Decimal
        
        init (dictionary: [String:AnyObject]) throws {
            let balanceRaw: String = try checkType(dictionary, name: "balance")
            let balanceDecimal = NumberUtils.decimalFormatter.number(from: balanceRaw)?.decimalValue
            self.balance = try checkType(balanceDecimal, name: "balanceDecimal")
            
            let totalInRaw: String = try checkType(dictionary, name: "totalIn")
            let totalInDecimal = NumberUtils.decimalFormatter.number(from: totalInRaw)?.decimalValue
            self.totalIn = try checkType(totalInDecimal, name: "totalInDecimal")
            
            let totalOutRaw: String = try checkType(dictionary, name: "totalOut")
            let totalOutDecimal = NumberUtils.decimalFormatter.number(from: totalOutRaw)?.decimalValue
            self.totalOut = try checkType(totalOutDecimal, name: "totalOutDecimal")
            
            self.tokenInfo = try TokenInfo.init(dictionary: dictionary["tokenInfo"] as! [String:AnyObject])

        }
    }
    
    struct TokenInfo {
        let address: String
        let name: String
        let decimals: Int
        let symbol: String
        let price: ExchangePrice
        
        init (dictionary: [String:AnyObject]) throws {
            self.address = try checkType(dictionary, name: "address")
            self.name = try checkType(dictionary, name: "name")
            self.decimals = try checkType(dictionary, name: "decimals")
            self.symbol = try checkType(dictionary, name: "symbol")
            self.price = try ExchangePrice.init(dictionary: dictionary["price"] as! [String : AnyObject])
        }
    }
    
    //empty info
    struct ExchangePrice {
        let rate: Decimal
        let currency: Currency
        let diff: Decimal
        let ts: Date
        
        init (dictionary: [String:AnyObject]) throws {
            let rateRaw: String = try checkType(dictionary, name: "rate")
            let rateDecimal = NumberUtils.decimalFormatter.number(from: rateRaw)?.decimalValue
            self.rate = try checkType(rateDecimal, name: "rateDecimal")
            
            self.currency = .common(traditional: .usd)
            
            let diffRaw: String = try checkType(dictionary, name: "diff")
            let diffDecimal = NumberUtils.decimalFormatter.number(from: diffRaw)?.decimalValue
            self.diff = try checkType(diffDecimal, name: "diffDecimal")
            
            let timestamp: TimeInterval = try checkType(dictionary, name: "ts")
            self.ts = Date.init(timeIntervalSinceReferenceDate: timestamp)
        }
    }
    
    var arrayOfEthplorerAccounts: [EthplorerAccount] {
        var arrayOlder = [EthplorerAccount]()
        let ethAccount = EthplorerAccount.init(type: .wallet, currency: self.currency, address: self.address, available: self.ETH.balance, altValue: 0, altCurrency: Currency.rawValue(shortName: "BTC"))
        arrayOlder.append(ethAccount)
        for ethplorerObject in self.tokens {
            let tokenAccount = EthplorerAccount.init(type: .wallet, currency: Currency.rawValue(shortName: ethplorerObject.tokenInfo.symbol), address: ethplorerObject.tokenInfo.address, available: ethplorerObject.balance, altValue: ethplorerObject.tokenInfo.price.rate, altCurrency: ethplorerObject.tokenInfo.price.currency)
            arrayOlder.append(tokenAccount)
        }
        return arrayOlder
    }
}
