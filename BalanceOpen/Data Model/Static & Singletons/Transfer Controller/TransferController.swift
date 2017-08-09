//
//  TransferController.swift
//  BalanceOpen
//
//  Created by Red Davis on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

/// Example: Coinbase, GDAX, ShapeShift
internal protocol TransferOperator
{
    init(request: TransferRequest)
    
    func perform(_ completionHandler: @escaping () -> Void)
}


internal protocol Transferable
{
    var directTransferManager: TransferOperator.Type { get }
    var exchangeTransferManager: TransferOperator.Type { get }
    
//    func make(withdrawal: Withdrawal, completionHandler: @escaping () -> Void)
}


internal final class TransferController
{
    // Private
    private let transferRequest: TransferRequest
    
    // MARK: Initialization
    
    internal init(request: TransferRequest)
    {
        self.transferRequest = request
    }
    
    // MARK: Quote
    
    // MARK: Transfer
    
    internal func performTransferRequest()
    {
        switch self.transferRequest.type
        {
        case .direct:()
        case .exchange:()
        }
    }
}


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
            // TODO: Throw error (unsupported currency)
            fatalError()
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
