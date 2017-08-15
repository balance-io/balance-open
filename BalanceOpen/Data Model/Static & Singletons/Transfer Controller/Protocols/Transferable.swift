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
    
    // TODO:
    // Determine if this is best approach.
    // For example, SS would be required to make a request
    // to determine if the currency conversion was supported
    func supportsTransfer(to account: Account) -> Bool
}


internal enum TransferableError: Error
{
    case transferNotSupported
}
