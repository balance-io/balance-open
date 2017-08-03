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
        
        internal let pairCode: String
        internal let expirationDate: Date
        internal let rate: Double
        internal let minerFee: Double
        
        internal let returnAddress: String?
        
        internal let recipientAddress: String
        internal let recipientAmount: Double
        
        internal let depositAddress: String
        internal let depositAmount: Double
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any]) throws
        {
            guard let identifier = dictionary["orderId"] as? String,
                  let pairCode = dictionary["pair"] as? String,
                  let recipientAddress = dictionary["withdrawal"] as? String,
                  let recipientAmountString = dictionary["withdrawalAmount"] as? String,
                  let recipientAmount = Double(recipientAmountString),
                  let depositAddress = dictionary["deposit"] as? String,
                  let depositAmountString = dictionary["depositAmount"] as? String,
                  let depositAmount = Double(depositAmountString),
                  let expirationTimeInterval = dictionary["expiration"] as? Double,
                  let rateString = dictionary["quotedRate"] as? String,
                  let rate = Double(rateString),
                  let minerFeeString = dictionary["minerFee"] as? String,
                  let minerFee = Double(minerFeeString) else
            {
                throw ModelError.invalidJSON(json: dictionary)
            }
        
            self.identifier = identifier
            self.pairCode = pairCode
            self.returnAddress = dictionary["returnAddress"] as? String
            self.recipientAddress = recipientAddress
            self.recipientAmount = recipientAmount
            self.depositAddress = depositAddress
            self.depositAmount = depositAmount
            self.expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
            self.rate = rate
            self.minerFee = minerFee
        }
    }
}
