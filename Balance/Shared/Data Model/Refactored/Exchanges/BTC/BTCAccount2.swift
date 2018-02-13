//
//  BTCAccount2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/13/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BTCAccount2: Codable {
    private var accountInstitutionId: Int = 0
    private var currency: Currency = .btc
    private let hash160: String
    private let address: String
    private let txCount: Int
    private let totalReceived: Int
    private let totalSent: Int
    private let finalBalance: Int
    
    enum CodingKeys: String, CodingKey {
        case hash160
        case address
        case txCount = "n_tx"
        case totalReceived = "total_received"
        case totalSent = "total_sent"
        case finalBalance = "final_balance"
    }
}

extension BTCAccount2: ExchangeAccount {
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
        return .blockchain
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var name: String {
        return currency.name
    }
    
    var currencyCode: String {
        return currency.code
    }
    
    var currentBalance: Int {
        return finalBalance
    }
    
    var availableBalance: Int {
        return currentBalance
    }
    
    var altCurrencyCode: String? {
        return nil
    }
    
    var altCurrentBalance: Int? {
        return nil
    }
    
    var altAvailableBalance: Int? {
        return nil
    }
}
