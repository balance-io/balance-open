//
//  EthplorerAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/7/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerAccount2: Codable {
    private var accountInstitutionId: Int = 0
    private var accountSource: Source = .ethplorer
    private let balance: Double
    private let tokenInfo: EthplorerToken

    enum CodingKeys: String, CodingKey {
        case balance
        case tokenInfo
    }
    
    init(balance: Double, tokenInfo: EthplorerToken) {
        self.balance = balance
        self.tokenInfo = tokenInfo
    }
}

struct EthplorerToken: Codable {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
    let price: EthplorerPrice
    
    init(address: String = "", name: String = "", symbol: String = "", decimals: Int = 0, price: EthplorerPrice) {
        self.address = address
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.price = price
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case name
        case symbol
        case decimals
        case price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address: String = try container.decode(String.self, forKey: .address)
        let name: String = try container.decode(String.self, forKey: .name)
        let symbol: String = try container.decode(String.self, forKey: .symbol)
        let decimalsInt: Int? = try? container.decode(Int.self, forKey: .decimals)
        let decimalsString: String? = try? container.decode(String.self, forKey: .decimals)
        let decimals = (decimalsInt ?? Int(decimalsString ?? "")) ?? 0
        let price: EthplorerPrice? = try? container.decode(EthplorerPrice.self, forKey: .price)
        
        self.init(address: address, name: name, symbol: symbol, decimals: decimals, price: price ?? EthplorerPrice(rate: 0))
    }
}

struct EthplorerPrice: Codable {
    let rate: Double
    let currency: Currency
    
    enum CodingKeys: String, CodingKey {
        case rate
    }
    
    init(rate: Double, currency: Currency = .usd) {
        self.rate = rate
        self.currency = currency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rate = try container.decode(String.self, forKey: .rate)
        self.init(rate: Double(rate) ?? 0)
    }
}
extension EthplorerAccount2: ExchangeAccount {
    var accountType: AccountType {
        return .wallet
    }
    
    var institutionId: Int {
        get {
            return accountInstitutionId
        }
        set {
            accountInstitutionId = newValue
        }
    }
    
    var source: Source {
        get {
            return accountSource
        }
        set {
            accountSource = newValue
        }
    }
    
    var sourceAccountId: String {
        return tokenInfo.symbol
    }
    
    var name: String {
        return tokenInfo.name
    }
    
    var currencyCode: String {
        return tokenInfo.symbol
    }
    
    var currentBalance: Int {
        if tokenInfo.decimals > 8 {
            return Int(balance.cientificToEightDecimals(decimals: tokenInfo.decimals))
        } else {
            return balance.integerValueWith(decimals: tokenInfo.decimals)
        }
    }
    
    var availableBalance: Int {
        return currentBalance
    }
    
    var altCurrencyCode: String? {
        return tokenInfo.price.currency.code
    }
    
    var altCurrentBalance: Int? {
        let altBalance = tokenInfo.price.rate * Double(availableBalance)
        return altBalance.integerValueWith(decimals: tokenInfo.price.currency.decimals)
    }
    
    var altAvailableBalance: Int? {
        return nil
    }
    
    
}
