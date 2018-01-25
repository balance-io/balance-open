//
//  NewPoloniexTransaction.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct NewPoloniexTransaction: ExchangeTransaction, Codable {
    
    var institutionId: Int = 0
    var source: Source = .poloniex
    var sourceInstitutionId: String = ""
    var sourceAccountId: String = ""
    var sourceTransactionId: String
    var name: String {
        return sourceTransactionId
    }
    var currencyCode: String = ""
    var amount: Int {
        return Int(amountString) ?? 0
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
        case sourceTransactionId = "idtx"
        case amountString = "amount"
        case currencyCode = "currency"
        case address
        case status
        case numberOfConfirmations = "confirmations"
        case timestamp
    }

}
