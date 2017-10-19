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
    
    internal let sectionIndexTitles: [String] 
    
    // Private
    private let groupedCurrencies: [String : [Currency]]
    
    // MARK: Initialization
    
    internal required init() {
        self.groupedCurrencies = Currency.masterCurrencies.reduce([String : [Currency]]()) { (result, currency) -> [String : [Currency]] in
            guard let firstCharacter = currency.code.first else {
                return result
            }
            
            let key = String(firstCharacter)
            var currencyArray = result[key] ?? [Currency]()
            currencyArray.append(currency)
            currencyArray.sort(by: { (currencyA, currencyB) -> Bool in
                return currencyA.code < currencyB.code
            })
            
            var mutableResults = result
            mutableResults[key] = currencyArray
            
            return mutableResults
        }
        
        self.sectionIndexTitles = self.groupedCurrencies.keys.sorted()
    }
    
    // MARK: -
    
    internal func numberOfCurrencies(at section: Int) -> Int {
        let key = self.sectionIndexTitles[section]
        return self.groupedCurrencies[key]!.count
    }
    
    internal func currency(at indexPath: IndexPath) -> Currency {
        let key = self.sectionIndexTitles[indexPath.section]
        let section = self.groupedCurrencies[key]!
        
        return section[indexPath.row]
    }
}
