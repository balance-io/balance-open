//
//  BITTREXDeposit.swift
//  Balance
//
//  Created by Benjamin Baron on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXDeposit: Codable {
    
    let id: Int
    let amount: Double
    let currency: String
    let confirmations: Int
    let lastUpdated: String
    let txId: String?
    let cryptoAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case amount = "Amount"
        case currency = "Currency"
        case confirmations = "Confirmations"
        case lastUpdated = "LastUpdated"
        case txId = "TxId"
        case cryptoAddress = "CryptoAddress"
    }
    
}

extension BITTREXDeposit {
    var date: Date? {
        return jsonWithMillisecondsDateFormatter.date(from: lastUpdated)
    }
}
