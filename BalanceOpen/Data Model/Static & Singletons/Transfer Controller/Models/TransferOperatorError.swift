//
//  TransferOperatorError.swift
//  BalanceOpen
//
//  Created by Red Davis on 16/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal enum TransferOperatorError: Error
{
    case unsupportedCurrency(currency: Currency)
}
