//
//  ShapeShiftQuote.swift
//  BalanceOpen
//
//  Created by Red Davis on 03/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension ShapeShiftAPIClient
{
    internal struct Quote
    {
        // Internal
        internal let identifier: String
        internal let pairCode: String
        internal let rate: Double
        internal let minerFee: Double
        
        internal let recipientAmount: Double
        internal let sourceAmount: Double
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any]) throws
        {
            guard let identifier = dictionary["orderId"] as? String,
                  let pairCode = dictionary["pair"] as? String,
                  let recipientAmountString = dictionary["withdrawalAmount"] as? String,
                  let recipientAmount = Double(recipientAmountString),
                  let sourceAmountString = dictionary["depositAmount"] as? String,
                  let sourceAmount = Double(sourceAmountString),
                  let rateString = dictionary["quotedRate"] as? String,
                  let rate = Double(rateString),
                  let minerFeeString = dictionary["minerFee"] as? String,
                  let minerFee = Double(minerFeeString) else
            {
                throw ModelError.invalidJSON(json: dictionary)
            }
            
            self.identifier = identifier
            self.pairCode = pairCode
            self.recipientAmount = recipientAmount
            self.sourceAmount = sourceAmount
            self.rate = rate
            self.minerFee = minerFee
        }
    }
}
