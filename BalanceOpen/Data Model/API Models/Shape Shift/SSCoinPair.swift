//
//  ShapeShiftCoinPair.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension ShapeShiftAPIClient
{
    internal struct CoinPair: Equatable
    {
        // Internal
        internal let input: Coin
        internal let output: Coin
        internal let code: String
        
        // MARK: Initialization
        
        internal init(input: Coin, output: Coin)
        {
            self.input = input
            self.output = output
            self.code = "\(input.symbol.lowercased())_\(output.symbol.lowercased())"
        }
    }
}

internal func ==(lhs: ShapeShiftAPIClient.CoinPair, rhs: ShapeShiftAPIClient.CoinPair) -> Bool
{
    return lhs.input == rhs.input && lhs.output == rhs.output
}
