//
//  TransferRequest.swift
//  BalanceOpen
//
//  Created by Red Davis on 14/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal struct TransferRequest
{
    // Internal
    internal let sourceAccount: Account
    internal let sourceInstitution: Institution
    internal let sourceCurrency: Currency
    internal let recipientAddress: String
    internal let recipientCurrency: Currency
    internal let amount: Double
    internal let type: RequestType
    
    // MARK: Initialization
    
    internal init(sourceAccount: Account, recipientAddress: String, recipientCurrency: Currency, amount: Double)
    {
        guard let sourceCurrency = Currency(rawValue: sourceAccount.currency),
              let sourceInstitution = sourceAccount.institution else
        {
            throw InitializationError.unsupportedCurrency(code: sourceAccount.currency)
        }
        
        self.sourceAccount = sourceAccount
        self.sourceInstitution = sourceInstitution
        self.sourceCurrency = sourceCurrency
        self.recipientAddress = recipientAddress
        self.recipientCurrency = recipientCurrency
        self.amount = amount
        self.type = sourceCurrency == recipientCurrency ? .direct : .exchange
    }
}


// MARK: Request Type

internal extension TransferRequest
{
    /**
     Request type.
     
     - direct: No currency exchange happens (ETH to ETH, GBP to GBP).
     - exchange: An exchange happens (ETH to BTC, BTC to GBP).
     */
    internal enum RequestType
    {
        case direct, exchange
    }
}


// MARK: Initialization error

internal extension TransferRequest
{
    /**
     Initialization error.
     
     - unsupportedCurrency: Unsupported currency
     */
    internal enum InitializationError: Error
    {
        case unsupportedCurrency(code: String)
    }
}

