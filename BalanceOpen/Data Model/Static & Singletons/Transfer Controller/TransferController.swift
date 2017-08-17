//
//  TransferController.swift
//  BalanceOpen
//
//  Created by Red Davis on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


/// The main class when handling transfers.
internal final class TransferController
{
    // Private
    private let transferRequest: TransferRequest
    private let transferOperator: TransferOperator
    
    // MARK: Initialization
    
    internal init(request: TransferRequest) throws
    {
        self.transferRequest = request
        
        let transferOperatorType: TransferOperator.Type
        switch transferRequest.type
        {
        case .direct:
            guard let operatorType = self.transferRequest.source.directTransferOperator else
            {
                throw InitializationError.directTransferUnsupported
            }
            
            transferOperatorType = operatorType
        case .exchange:
            guard let operatorType = self.transferRequest.source.exchangeTransferOperator else
            {
                throw InitializationError.exchangeTransferUnsupported
            }
            
            transferOperatorType = operatorType
        }
        
        self.transferOperator = transferOperatorType.init(request: request)
    }
    
    // MARK: Quote
    
    /**
     Fetches a quote. Can be used to display transfer details and fees to the user
     
     - Parameter completionHandler
     - Parameter quote
     - Parameter error
    */
    internal func fetchQuote(_ completionHandler: @escaping (_ quote: TransferQuote?, _ error: Error?) -> Void)
    {
        self.transferOperator.fetchQuote(completionHandler)
    }
    
    // MARK: Transfer
    
    internal func performTransferRequest(_ completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        self.transferOperator.performTransfer(completionHandler)
    }
}


// MARK: Initialization error

internal extension TransferController
{
    internal enum InitializationError: Error
    {
        case directTransferUnsupported
        case exchangeTransferUnsupported
    }
}
