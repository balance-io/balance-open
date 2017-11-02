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
        var currencySet = Set<Currency>()
        if let rates = currentExchangeRates.exchangeRates(forSource: .poloniex) {
            for rate in rates {
                currencySet.insert(rate.from)
            }
        }
        currencies = Array(currencySet).sorted(by: { $0.code < $1.code })
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
}
