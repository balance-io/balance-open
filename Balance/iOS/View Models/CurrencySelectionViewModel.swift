//
//  CurrencySelectionViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 17/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class CurrencySelectionViewModel {
    // Internal
    internal var numberOfSections: Int {
        return self.sectionIndexTitles.count
    }
    
    internal let sectionIndexTitles: [String?] = [nil, "Fiat Currencies", "Crypto Currencies"]
    
    internal var currencies: [[String]] {
        return [["Automatic - \(NSLocale.current.currencyCode ?? "USD")", "USD", "EUR", "GBP"],
                ["AUD", "CAD", "CNY", "DKK", "HKD", "JPY"],
                ["BTC", "ETH", "LTC"]]
    }
    
    internal var currentCurrencyDisplay: String {
        if defaults.isMasterCurrencySet {
            return defaults.masterCurrency.longName
        } else {
            return currencies[0][0]
        }
    }
    
    // MARK: -
    
    internal func numberOfCurrencies(at section: Int) -> Int {
        guard section >= 0 && section < currencies.count else {
            return 0
        }
        
        return currencies[section].count
    }
    
    internal func currency(at indexPath: IndexPath) -> Currency {
        let code = currencies[indexPath.section][indexPath.row]
        return Currency.rawValue(code)
    }
    
    internal func currencyDisplay(at indexPath: IndexPath) -> String {
        if indexPath.section == 0 && indexPath.row == 0 {
            return currencies[0][0]
        } else {
            return self.currency(at: indexPath).longName
        }
    }
    
    internal func isCurrencySelected(at indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 0 {
            return !defaults.isMasterCurrencySet
        } else {
            return defaults.isMasterCurrencySet && currency(at: indexPath) == defaults.masterCurrency
        }
    }
    
    internal func selectCurrency(at indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            defaults.masterCurrency = nil
        } else {
            let code = currencies[indexPath.section][indexPath.row]
            defaults.masterCurrency = Currency.rawValue(code)
        }
    }
}
