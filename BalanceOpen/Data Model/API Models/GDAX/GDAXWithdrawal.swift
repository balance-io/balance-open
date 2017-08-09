//
//  GDAXWithdrawal.swift
//  BalanceOpen
//
//  Created by Red Davis on 01/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension GDAXAPIClient
{
    internal struct Withdrawal
    {
        // Internal
        internal let amount: Double
        internal let currencyCode: String
        internal let recipientCryptoAddress: String
        
        // Private
        private var dictionaryRepresentation: [String : Any] {
            return [
                "amount" : self.amount,
                "currency" : self.currencyCode,
                "crypto_address" : self.recipientCryptoAddress
            ]
        }
        
        // MARK: JSON
        
        internal func jsonData() throws -> Data
        {
            return try JSONSerialization.data(withJSONObject: self.dictionaryRepresentation, options: [])
        }
    }
}
