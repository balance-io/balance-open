//
//  NewPoloniexTransaction.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexTransaction: ExchangeTransaction, Codable {
    
    var category: TransactionType = .unknown
    var institutionId: Int = 0
    var source: Source = .poloniex
    var sourceInstitutionId: String = ""
    var currencyCode: String
    var sourceTransactionId: String
    
    var sourceAccountId: String {
        return currencyCode
    }
    
    var name: String {
        return sourceTransactionId
    }
    
    var amount: Int {
        return Double(amountString)?
            .integerValueWith(decimals: Currency.rawValue(currencyCode).decimals) ?? 0
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    // MARK: API specific values
    let address: String
    let status: String
    let numberOfConfirmations: Int
    let timestamp: TimeInterval
    let amountString: String
    
    enum CodingKeys: String, CodingKey {
        case sourceTransactionId = "txid"
        case amountString = "amount"
        case currencyCode = "currency"
        case address
        case status
        case numberOfConfirmations = "confirmations"
        case timestamp
    }

}
