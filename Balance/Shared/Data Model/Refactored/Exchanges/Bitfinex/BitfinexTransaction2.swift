//
//  BitfinexTransaction2.swift
//  BalancemacOS
//
//  Created by Felipe Rolvar on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BitfinexTransaction2 {
    private var txType: String = ""
    private var txInstitutionId: Int = 0
    private var txSourceInstitutionId: String = ""
    private let currency: Currency
    private let address: String
    private let status: String
    private let txAmount: Double
    private let createdAt: Double
    private let updatedAt: Double
    private var identifier: String {
        return "\(address)\(txAmount)\(updatedAt)"
    }
    
    init(currency: Currency, address: String, status: String, amount: Double, createdAt: Double, updatedAt: Double) {
        self.currency = currency
        self.address = address
        self.status = status
        self.txAmount = amount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension BitfinexTransaction2: ExchangeTransaction {
    var type: String {
        get {
            return txType
        }
        set {
            txType = newValue
        }
    }
    
    var institutionId: Int {
        get {
            return txInstitutionId
        }
        set {
            txInstitutionId = newValue
        }
    }
    
    var source: Source {
        return .bitfinex
    }
    
    var sourceInstitutionId: String {
        get {
            return txSourceInstitutionId
        }
        set {
            txSourceInstitutionId = newValue
        }
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var sourceTransactionId: String {
        return identifier
    }
    
    var name: String {
        return identifier
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: createdAt.milisecondsToSeconds())
    }
    
    var currencyCode: String {
        return currency.code
    }
    
    var amount: Int {
        return txAmount.integerValueWith(decimals: currency.decimals)
    }
}
