//
//  CoinbaseTransaction.swift
//  Balance
//
//  Created by Red Davis on 21/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension CoinbaseApi {
    internal struct Transaction {
        // Internal
        internal let identifier: String
        internal let type: String
        internal let status: String
        internal let createdAt: Date
        internal let updatedAt: Date
        
        internal let amount: Double
        internal let currencyCode: String
        
        internal let nativeAmount: Double
        internal let nativeCurrencyCode: String
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any]) throws {
            guard let identifier = dictionary["id"] as? String,
                  let type = dictionary["type"] as? String,
                  let status = dictionary["status"] as? String,
                  let amountDictionary = dictionary["amount"] as? [String : Any],
                  let amountString = amountDictionary["amount"] as? String,
                  let amount = Double(amountString),
                  let currencyCode = amountDictionary["currency"] as? String,
                  let nativeAmountDictionary = dictionary["native_amount"] as? [String : Any],
                  let nativeAmountString = nativeAmountDictionary["amount"] as? String,
                  let nativeAmount = Double(nativeAmountString),
                  let nativeCurrencyCode = nativeAmountDictionary["currency"] as? String,
                  let createdAtString = dictionary["created_at"] as? String,
                  let createdAt = jsonDateFormatter.date(from: createdAtString),
                  let updatedAtString = dictionary["updated_at"] as? String,
                  let updatedAt = jsonDateFormatter.date(from: updatedAtString) else
            {
                throw "Invalid dictionary \(dictionary)"
            }
            
            self.identifier = identifier
            self.type = type
            self.status = status
            self.amount = amount
            self.currencyCode = currencyCode
            self.nativeAmount = nativeAmount
            self.nativeCurrencyCode = nativeCurrencyCode
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}


//{
//    "id": "57ffb4ae-0c59-5430-bcd3-3f98f797a66c",
//    "type": "send",
//    "status": "completed",
//    "amount": {
//        "amount": "-0.00100000",
//        "currency": "BTC"
//    },
//    "native_amount": {
//        "amount": "-0.01",
//        "currency": "USD"
//    },
//    "description": null,
//    "created_at": "2015-03-11T13:13:35-07:00",
//    "updated_at": "2015-03-26T15:55:43-07:00",
//    "resource": "transaction",
//    "resource_path": "/v2/accounts/2bbf394c-193b-5b2a-9155-3b4732659ede/transactions/57ffb4ae-0c59-5430-bcd3-3f98f797a66c",
//    "network": {
//        "status": "off_blockchain",
//        "name": "bitcoin"
//    },
//    "to": {
//        "id": "a6b4c2df-a62c-5d68-822a-dd4e2102e703",
//        "resource": "user",
//        "resource_path": "/v2/users/a6b4c2df-a62c-5d68-822a-dd4e2102e703"
//    },
//    "instant_exchange": false,
//    "details": {
//        "title": "Sent bitcoin",
//        "subtitle": "to User 2"
//    }
//}

