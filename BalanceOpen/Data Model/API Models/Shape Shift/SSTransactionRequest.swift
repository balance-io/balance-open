//
//  ShapeShiftTransactionRequest.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension ShapeShiftAPIClient
{
    internal struct TransactionRequest
    {
        // Internal
        internal let identifier: String
        internal let returnAddress: String?
        internal let recipientAddress: String
        internal let depositAddress: String
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any]) throws
        {
            guard let identifier = dictionary["orderId"] as? String,
                  let recipientAddress = dictionary["withdrawal"] as? String,
                  let depositAddress = dictionary["deposit"] as? String else
            {
                throw ModelError.invalidJSON(json: dictionary)
            }
        
            self.identifier = identifier
            self.returnAddress = dictionary["returnAddress"] as? String
            self.recipientAddress = recipientAddress
            self.depositAddress = depositAddress
        }
    }
}
