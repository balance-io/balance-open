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
    internal let operatorType: TransferOperator.Type

    // MARK: Initialization
    
    internal init(source: Transferable, recipient: Transferable, amount: Double) throws
    {
        self.source = source
        self.sourceCurrency = source.currencyType
        self.recipient = recipient
        self.recipientCurrency = recipient.currencyType
        self.amount = amount
        self.type = self.sourceCurrency == self.recipientCurrency ? .direct : .exchange
        
        // Transfer type validations
        switch self.type
        {
        case .direct:
            guard let operatorType = source.directTransferOperator else
            {
                throw InitializationError.directTransferUnsupported
            }
            
            self.operatorType = operatorType
        case .exchange:
            guard let operatorType = source.exchangeTransferOperator else
            {
                throw InitializationError.exchangeTransferUnsupported
            }
            
            self.operatorType = operatorType
        }
        
        // Source validations
        if !source.canMakeWithdrawal { throw InitializationError.sourceAccountDoesNotSupportWithdrawing }
        
        // Recipient validations
        if !recipient.canRequestCryptoAddress { throw InitializationError.recipientAccountDoesNotSupportAccessingCryptoAddress }
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

// MARK:

internal extension TransferRequest
{
    internal enum InitializationError: Error
    {
        case directTransferUnsupported
        case exchangeTransferUnsupported
        case sourceAccountDoesNotSupportWithdrawing
        case recipientAccountDoesNotSupportAccessingCryptoAddress
    }
}
