//
//  Transferable.swift
//  BalanceOpen
//
//  Created by Red Davis on 10/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


// TODO: This needs a better name
internal protocol Transferable
{
    var directTransferOperator: TransferOperator.Type? { get }
    var exchangeTransferOperator: TransferOperator.Type? { get }
    
    func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) throws
}


internal enum TransferableError: Error
{
    case transferNotSupported
}
