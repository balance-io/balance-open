//
//  NewPoloniexTransaction.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexTransaction: Codable {
    private var transactionType: String = ""
    private var transactionInstitution: Int = 0
    private var transactionSourceInstitution: String = ""
    private var transactionId: String
    private var currency: String
    private let address: String
    private let status: String
    private let numberOfConfirmations: Int
    private let timestamp: TimeInterval
    private let amountString: String
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "txid"
        case amountString = "amount"
        case currency
        case address
        case status
        case numberOfConfirmations = "confirmations"
        case timestamp
    }
}

// MARK: Protocol

extension NewPoloniexTransaction: ExchangeTransaction {
    var type: String {
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
        return .poloniex
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
        return transactionId
    }
    
    var name: String {
        return transactionId
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    var currencyCode: String {
        return currency
    }
    
    var amount: Int {
        return Double(amountString)?.integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
}
