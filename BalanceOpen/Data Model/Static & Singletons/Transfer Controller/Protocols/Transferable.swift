//
//  Transferable.swift
//  BalanceOpen
//
//  Created by Red Davis on 10/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal protocol Transferable
{
    var currencyType: Currency { get }
    var directTransferOperator: TransferOperator.Type? { get }
    var exchangeTransferOperator: TransferOperator.Type? { get }
    
    func make(withdrawal: Withdrawal, completionHandler: @escaping (_ success: Bool, _ error: Error?) -> Void) throws
    func fetchAddress(_ completionHandler: @escaping (_ address: String?, _ error: Error?) -> Void) throws
}

internal enum TransferableError: Error
{
    case unsupported
}
