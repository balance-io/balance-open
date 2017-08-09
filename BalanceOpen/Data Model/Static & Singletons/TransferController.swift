//
//  TransferController.swift
//  BalanceOpen
//
//  Created by Red Davis on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class InternalTransferController
{
    // Private
    private let transferRequest: InternalTransferRequest
    
    // MARK: Initialization
    
    internal init(request: InternalTransferRequest)
    {
        self.transferRequest = request
    }
}


internal struct InternalTransferRequest
{
    // Internal
    internal let sourceAccount: Account
    internal let recipientAccount: Account
    internal let amount: Double
}
