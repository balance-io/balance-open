//
//  TransferQuote.swift
//  BalanceOpen
//
//  Created by Red Davis on 10/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal struct TransferQuote
{
    // Internal
    internal let rate: Double
    internal let minerFee: Double
    internal let recipientAmount: Double
    internal let depositAmount: Double
}

// MARK: Shape Shift

internal extension TransferQuote
{
    internal init(shapeShiftQuote: ShapeShiftAPIClient.Quote)
    {
        self.rate = shapeShiftQuote.rate
        self.minerFee = shapeShiftQuote.minerFee
        self.recipientAmount = shapeShiftQuote.recipientAmount
        self.depositAmount = shapeShiftQuote.depositAmount
    }
}
