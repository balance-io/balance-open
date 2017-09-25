//
//  KrakenAccount.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


/**
 Note about Kraken currency codes:
 - https://github.com/CliffS/kraken-exchange/blob/master/README.md
 - https://www.reddit.com/r/Bitcoin/comments/20ff0x/one_downside_of_kraken_is_how_the_currency_pairs/
 
 Need to figure out a good, non-brittle way to handle this.
 */
internal extension KrakenAPIClient {
    internal struct Account {
        // Internal
        internal let currencyCode: String
        internal let balance: Double
        
        // MARK: Initialization
        
        internal init(currency: String, balance: String) throws {
            guard let balanceDouble = Double(balance) else {
                throw ModelError.invalidJSON(json: balance)
            }
            
            self.currencyCode = currency
            self.balance = balanceDouble
        }
    }
}
