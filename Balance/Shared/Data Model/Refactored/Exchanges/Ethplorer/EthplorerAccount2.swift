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
    private let altCurrencyInfo: EthToken
    
    enum CodingKeys: String, CodingKey {
        case balance
        case tokenInfo
        case altCurrencyInfo = "ETH"
    }
}

struct EthplorerToken: Codable {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
    
    init(address: String = "", name: String = "", symbol: String = "", decimals: Int = 0) {
        self.address = address
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }
    
    enum CodingKeys: String, CodingKey {
        case address
        case name
        case symbol
        case decimals
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address: String = try container.decode(String.self, forKey: .address)
        let name: String = try container.decode(String.self, forKey: .name)
        let symbol: String = try container.decode(String.self, forKey: .symbol)
        let decimalsInt: Int? = try? container.decode(Int.self, forKey: .decimals)
        let decimalsString: String? = try? container.decode(String.self, forKey: .decimals)
        
        let decimals = (decimalsInt ?? Int(decimalsString ?? "")) ?? 0
        
        self.init(address: address, name: name, symbol: symbol, decimals: decimals)
    }
}

struct EthToken: Codable {
    let currency: Currency = .eth
    let balance: Double
    let totalIn: Double
    let totalOut: Double
    
    enum CodingKeys: String, CodingKey {
        case balance
        case totalIn
        case totalOut
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
        return balance.integerValueWith(decimals: tokenInfo.decimals)
    }
    
    var availableBalance: Int {
        return currentBalance
    }
    
    var altCurrencyCode: String? {
        return altCurrencyInfo.currency.code
    }
    
    var altCurrentBalance: Int? {
        return altCurrencyInfo.balance.integerValueWith(decimals: tokenInfo.decimals)
    }
    
    var altAvailableBalance: Int? {
        return altCurrentBalance
    }
    
    
}
