//
//  PlaidTransaction.swift
//  Balance
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

public struct PlaidTransaction {
    
    public let transactionId: String
    public let accountId: String
    public let amount: Double
    public let date: String
    public let name: String
    public let pending: Bool
    
    public let category: [String]?
    public let categoryId: String?
    
    public let address: String?
    public let city: String?
    public let state: String?
    public let zip: String?
    public let latitude: Double?
    public let longitude: Double?
    
    public init(transaction: [String: AnyObject]) throws {
        transactionId = try checkType(transaction["transaction_id"], name: "transaction_id")
        accountId = try checkType(transaction["account_id"], name: "account_id")
        amount = try checkType(transaction["amount"], name: "amount")
        date = try checkType(transaction["date"], name: "date")
        name = try checkType(transaction["name"], name: "name")
        pending = try checkType(transaction["pending"], name: "pending")
        
        category = transaction["category"] as? [String]
        categoryId = transaction["category_id"] as? String
        
        let location = transaction["location"] as? [String: Any]
        address = location?["address"] as? String
        city = location?["city"] as? String
        state = location?["state"] as? String
        zip = location?["zip"] as? String
        latitude = location?["lat"] as? Double
        longitude = location?["lon"] as? Double
    }
}
