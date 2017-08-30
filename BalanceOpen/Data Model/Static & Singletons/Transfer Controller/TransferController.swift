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
    
    internal init(request: TransferRequest)
    {
        self.transferRequest = request
        self.transferOperator = request.operatorType.init(request: request)
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
