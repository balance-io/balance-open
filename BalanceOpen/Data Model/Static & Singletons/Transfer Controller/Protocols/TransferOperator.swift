//
//  TransferOperator.swift
//  BalanceOpen
//
//  Created by Red Davis on 10/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


/**
 An object that conforms to TransferOperator can be used by the
 TransferController to perform transfers.
 
 Examples of transfer operators:
 
 - ShapeShift
 - Coinbase
 - GDAX
 */
internal protocol TransferOperator
{
    init(request: TransferRequest)
    func performTransfer(_ completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void)
    func fetchQuote(_ completionHandler: @escaping (_ quote: TransferQuote?, _ error: Error?) -> Void)
}
