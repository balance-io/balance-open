//
//  Double.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 19/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Double {
    
    func integerFixedFiatDecimals() -> Int {
        let fixedDecimalsFiat = 2
        return self.integerValueWith(decimals:fixedDecimalsFiat)
    }
    
    func integerFixedCryptoDecimals() -> Int {
        let fixedDecimalsCrypto = 8
        return self.integerValueWith(decimals:fixedDecimalsCrypto)
    }
    
    func integerValueWith(decimals: Int) -> Int {
        let balanceString = String(format:"%f", self * Double(pow(10.0, Double(decimals))))
        let integerPart = balanceString.components(separatedBy: ".")[0]
        let availableDecimal = NumberUtils.decimalFormatter.number(from: integerPart)?.decimalValue
        return (availableDecimal! as NSDecimalNumber).intValue
    }
    
    func cientificToEightDecimals(decimals: Int) -> Double {
        let decimal = self / pow(10.0, Double(decimals))
        return decimal
    }
    
    func milisecondsToSeconds() -> Double {
        return self/1000.0
    }
}

