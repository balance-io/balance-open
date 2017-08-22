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
    internal let source: Transferable
    internal let sourceCurrency: Currency
    
    internal let recipient: Transferable
    internal let recipientCurrency: Currency
    
    internal let amount: Double
    internal let type: RequestType

    // MARK: Initialization
    
    internal init(source: Transferable, recipient: Transferable, amount: Double)
    {
        self.source = source
        self.sourceCurrency = source.currencyType
        self.recipient = recipient
        self.recipientCurrency = recipient.currencyType
        self.amount = amount
        self.type = self.sourceCurrency == self.recipientCurrency ? .direct : .exchange
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
