//
//  PriceTickerTabViewModel.swift
//  Balance
//
//  Created by Benjamin Baron on 11/2/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class PriceTickerTabViewModel: TabViewModel {
    
    var currencies = [Currency]()
    
    func reloadData() {
        let topCurrencyCodes = ["BTC", "ETH", "LTC", "BCH", "XRP", "DASH", "MIOTA", "ETC", "XMR", "LSK", "STEEM", "GNT", "ZRX"]
        
        var otherCurrenciesSet = Set<Currency>()
        if let rates = currentExchangeRates.allExchangeRates() {
            for rate in rates {
                if !topCurrencyCodes.contains(rate.from.code) {
                    otherCurrenciesSet.insert(rate.from)
                }
            }
        }
        
        let topCurrencies = topCurrencyCodes.map({ Currency.rawValue($0) })
        let otherCurrencies = Array(otherCurrenciesSet).sorted(by: { $0.code < $1.code })
        
        currencies = topCurrencies + otherCurrencies
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return currencies.count
    }
    
    func currency(forRow row: Int, inSection section: Int) -> Currency? {
        if row < currencies.count {
            return currencies[row]
        }
        return nil
    }
    
    func ratesString(forRow row: Int, inSection section: Int) -> String {
        var convertedAmountString = "Unknown"
        if let currency = currency(forRow: row, inSection: section) {
            if let convertedAmountDouble = currentExchangeRates.convertTicker(amount: 1.0, from: currency, to: defaults.masterCurrency) {
                // Handle cases of less than one cent in fiat currencies
                if defaults.masterCurrency.decimals == 2 && convertedAmountDouble < 0.01 {
                    let decimals = 8
                    let convertedAmountInt = convertedAmountDouble.integerValueWith(decimals: decimals)
                    convertedAmountString = amountToString(amount: convertedAmountInt, currency: defaults.masterCurrency, decimalsOverride: decimals, showNegative: true)
                } else {
                    let convertedAmountInt = convertedAmountDouble.integerValueWith(decimals: defaults.masterCurrency.decimals)
                    convertedAmountString = amountToString(amount: convertedAmountInt, currency: defaults.masterCurrency, showNegative: true)
                }
            }
        }
        return convertedAmountString
    }
}
