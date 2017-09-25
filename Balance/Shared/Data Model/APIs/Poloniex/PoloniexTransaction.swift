//
//  PoloniexTransaction.swift
//  Balance
//
//  Created by Red Davis on 25/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension PoloniexApi {
    internal struct Transaction {
        // Internal
        internal let identifier: String
        internal let category: Category
        internal let address: String
        internal let amount: Double
        internal let currencyCode: String
        internal let status: String
        internal let timestamp: Date
        internal let numberOfConfirmations: Int?
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any], category: Category) throws {
            guard let amountString = dictionary["amount"] as? String,
                  let amount = Double(amountString) else {
                    throw PoloniexApi.CredentialsError.bodyNotValidJSON
            }
            
            self.category = category
            self.amount = amount
            self.identifier = try checkType(dictionary["txid"], name: "txid")
            self.address = try checkType(dictionary["address"], name: "address")
            self.currencyCode = try checkType(dictionary["currency"], name: "currency")
            self.status = try checkType(dictionary["status"], name: "status")
            self.numberOfConfirmations = dictionary["confirmations"] as? Int
            
            let unixTimestamp: TimeInterval = try checkType(dictionary["timestamp"], name: "timestamp")
            self.timestamp = Date(timeIntervalSince1970: unixTimestamp)
        }
        
        internal init(withdrawalDictionary: [String : Any]) throws {
            try self.init(dictionary: withdrawalDictionary, category: .withdrawal)
        }
        
        internal init(depositDictionary: [String : Any]) throws {
            try self.init(dictionary: depositDictionary, category: .deposit)
        }
    }
}

// MARK: Type

internal extension PoloniexApi.Transaction {
    internal enum Category {
        case unknown
        case withdrawal
        case deposit
    }
}
