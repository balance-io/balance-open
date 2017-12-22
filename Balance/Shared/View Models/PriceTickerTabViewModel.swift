//
//  PriceTickerTabViewModel.swift
//  Balance
//
//  Created by Benjamin Baron on 11/2/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum PriceTickerSection: Int {
    case portfolio = 0
    case popular = 1
    case other = 2
}

class PriceTickerTabViewModel: TabViewModel {
    
    let allPopularCurrencies: [Currency] = [Currency.rawValue("BTC"), Currency.rawValue("ETH"), Currency.rawValue("LTC"),
                                            Currency.rawValue("BCH"), Currency.rawValue("XRP"), Currency.rawValue("DASH"),
                                            Currency.rawValue("MIOTA"), Currency.rawValue("ETC"), Currency.rawValue("XMR"),
                                            Currency.rawValue("LSK"), Currency.rawValue("STEEM"), Currency.rawValue("GNT"),
                                            Currency.rawValue("ZRX")]
    
    var currencies = [[Currency]]()
    var showPortfolio: Bool {
        return currencies.count > 0 && currencies[0].count > 0
    }
    
    // All currencies owned by the user that have an exchange rate
    var portfolioCurrencies: [Currency] {
        var portfolioCurrenciesSet = Set<Currency>()
        let allAcounts = AccountRepository.si.allAccounts()
        for account in allAcounts {
            let currency = Currency.rawValue(account.currency)
            if currency.isCrypto && currentExchangeRates.convertTicker(amount: 1.0, from: currency, to: defaults.masterCurrency) != nil {
                portfolioCurrenciesSet.insert(currency.primaryCurrency)
            }
        }
        
        let portfolioCurrencies = Array(portfolioCurrenciesSet).sorted(by: { $0.code < $1.code })
        return portfolioCurrencies
    }
    
    func reloadData() {
        let portfolio = portfolioCurrencies
        
        // Find the popular currencies not owned by the user
        var popular = [Currency]()
        for currency in allPopularCurrencies {
            if !portfolio.contains(currency) {
                popular.append(currency)
            }
        }
        
        // Find all other currencies not owned by the user
        var otherSet = Set<Currency>()
        if let rates = currentExchangeRates.allExchangeRates() {
            for rate in rates {
                if !portfolio.contains(rate.from) && !popular.contains(rate.from) {
                    otherSet.insert(rate.from)
                }
            }
        }
        let other = Array(otherSet).sorted(by: { $0.code < $1.code })
        
        currencies = [portfolio, popular, other]
    }
    
    func numberOfSections() -> Int {
        return showPortfolio ? 3 : 2
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        let adjustedSection = showPortfolio ? section : section + 1
        return currencies[adjustedSection].count
    }
    
    func adjustedSection(_ section: Int) -> Int {
        return showPortfolio ? section : section + 1
    }
    
    func name(forSection section: Int) -> String {
        guard let priceTickerSection = PriceTickerSection(rawValue: adjustedSection(section)) else {
            return ""
        }
        
        switch priceTickerSection {
        case .portfolio: return "Portfolio"
        case .popular:   return "Popular"
        case .other:     return "Other"
        }
    }
    
    func currency(forRow row: Int, inSection section: Int) -> Currency? {
        let adjustedSection = self.adjustedSection(section)
        if adjustedSection < currencies.count && row < currencies[adjustedSection].count {
            return currencies[adjustedSection][row]
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
