//
//  ShapeShiftTransferOperator.swift
//  BalanceOpen
//
//  Created by Red Davis on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class ShapeShiftTransferOperator: TransferOperator
{
    // Private
    private let apiClient: ShapeShiftAPIClient = {
        let client = ShapeShiftAPIClient()
//        client.apiKey = ""
        return client
    }()
    
    // MARK: Initialization
    
    internal init(request: TransferRequest)
    {
        
    }
    
    // MARK: Quote
    
    internal func fetchQuote(_ completionHandler: @escaping () -> Void)
    {
        
    }
    
    // MARK: Transfer
    
    internal func performTransfer(_ completionHandler: @escaping () -> Void)
    {
        // TODO:
    }
}
