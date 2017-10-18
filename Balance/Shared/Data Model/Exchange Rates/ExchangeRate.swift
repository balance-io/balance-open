//
//  ExchangeRate.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 9/29/17.
//

import Foundation

public struct ExchangeRate {
    let source: ExchangeRateSource
    let from: Currency
    let to: Currency
    let rate: Double
}

public extension Array where Element == ExchangeRate {
    public func contains(from: Currency, to: Currency) -> Bool {
        return self.contains(where: {$0.from == from && $0.to == to})
    }
    
    public func rate(from: Currency, to: Currency) -> Double? {
        if let index = self.index(where: {$0.from == from && $0.to == to}) {
            return self[index].rate
        }
        return nil
    }
}
