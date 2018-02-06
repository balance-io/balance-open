//
//  CoinbaseTransaction2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/5/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct CoinbaseTransaction2: Codable {
    private var transactionInstitution: Int = 0
    private var transactionType: TransactionType
    private var transactionSourceInstitution: String = ""
    private let identifier: String
    private let status: String
    private let created: String
    private let updated: String
    private let amountValue: Double
    private let currency: String
    private let nativeBalanceDict: BalanceDict
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case transactionType = "type"
        case status
        case created = "created_at"
        case updated = "updated_at"
        case amountValue = "amount"
        case currency
        case nativeBalanceDict = "native_amount"
    }
}

// MARK: Protocol

extension CoinbaseTransaction2: ExchangeTransaction {
    var type: TransactionType {
        get {
            return transactionType
        }
        set {
            transactionType = newValue
        }
    }
    
    var institutionId: Int {
        get {
            return transactionInstitution
        }
        set {
            transactionInstitution = newValue
        }
    }
    
    var source: Source {
        return .coinbase
    }
    
    var sourceInstitutionId: String {
        get {
            return transactionSourceInstitution
        }
        set {
            transactionSourceInstitution = newValue
        }
    }
    
    var sourceAccountId: String {
        return currencyCode
    }
    
    var sourceTransactionId: String {
        return identifier
    }
    
    var name: String {
        return identifier
    }
    
    var date: Date {
        return jsonDateFormatter.date(from: created) ?? Date()
    }
    
    var currencyCode: String {
        return currency
    }
    
    var amount: Int {
        return Int(amountValue)
    }
}
