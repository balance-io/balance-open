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
    internal let minerFeeCurrency: Currency
    
    internal let sourceAmount: Double
    internal let sourceCurrency: Currency
    
    internal let recipientAmount: Double
    internal let recipientCurrency: Currency
    
    internal let maximumAmount: Double
    internal let minimumAmount: Double
}

// MARK: Shape Shift

internal extension TransferQuote
{
    internal init(sourceAmount: Double, marketInformation: ShapeShiftAPIClient.MarketInformation) throws
    {
        guard let sourceCurrency = Currency(rawValue: marketInformation.coinPair.input.symbol.uppercased()),
              let recipientCurrency = Currency(rawValue: marketInformation.coinPair.output.symbol.uppercased()) else
        {
            throw InitializationError.invalidCurrency
        }
        
        self.rate = marketInformation.rate
        self.minerFee = marketInformation.minerFee
        self.minerFeeCurrency = recipientCurrency // SS miner currency is always in the recipient currenct
        self.sourceAmount = sourceAmount
        self.sourceCurrency = sourceCurrency
        self.recipientAmount = sourceAmount * marketInformation.rate
        self.recipientCurrency = recipientCurrency
        self.maximumAmount = marketInformation.maximumDepositLimit
        self.minimumAmount = marketInformation.minimumDepositLimit
    }
}

// MARK: Initialization

internal extension TransferQuote
{
    internal enum InitializationError: Error
    {
        case invalidCurrency
    }
}
