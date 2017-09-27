//
//  BitfinexTransaction.swift
//  Balance
//
//  Created by Red Davis on 27/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

/**
 Bitfinex documentation is incomplete!
 It also doesn't help that the data is returned in an array.
 
 Below is a response that I'm trying to label the values:
 
 3195531,
 BTC, currency code 1
 BITCOIN, currency name 2
 "<null>",
 "<null>",
 1503488496000, movement 5
 1503490418000, created 6
 "<null>",
 "<null>",
 COMPLETED, 9
 "<null>",
 "<null>",
 "0.015113", 12 amount
 0,
 "<null>",
 "<null>",
 1NHtGHaHVNUJejhqTmGKPr9zbwah8Ppnj9, address 16
 "<null>",
 "<null>",
 "<null>",
 ef74878c602b1cf12e766f87a3fc0e91fadf5e2762bc14bf8a7206e0a1d9c5cd,
 "<null>"
 
 */


internal extension BitfinexAPIClient
{
    internal struct Transaction
    {
        // Internal
        internal let currencyCode: String
        internal let address: String
        internal let status: String
        internal let amount: Double
        internal let createdAt: Date
        internal let movementTimestamp: Date

        // MARK: Initialization
        
        internal init(data: [Any]) throws
        {
            guard data.count == 22 else
            {
                throw BitfinexAPIClient.ModelError.invalidJSON(json: data)
            }
            
            guard let currencyCode = data[1] as? String,
                  let address = data[16] as? String,
                  let status = data[9] as? String,
                  let amount = data[12] as? Double,
                  let createdAtTimeInterval = data[6] as? TimeInterval,
                  let movementTimeInterval = data[5] as? TimeInterval else
            {
                throw BitfinexAPIClient.ModelError.invalidJSON(json: data)
            }
            
            self.currencyCode = currencyCode
            self.address = address
            self.status = status
            self.amount = amount
            self.createdAt = Date(timeIntervalSince1970: createdAtTimeInterval)
            self.movementTimestamp = Date(timeIntervalSince1970: movementTimeInterval)
        }
    }
}
