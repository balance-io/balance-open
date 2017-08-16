//
//  TransferFundsViewModel.swift
//  BalanceOpen
//
//  Created by Red Davis on 15/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class TransferFundsViewModel
{
    // Internal
    internal var sourceAccount: Account?
    internal var recipientAccount: Account?
    
    internal var accountNames: [String] {
        return Array(self.accounts.keys)
    }
    
    internal var sourceCurrencies: [Currency] {
        let usd = Currency.usd // TODO: This will be the selected "global" currency
        
        guard let sourceCurrencyValue = self.sourceAccount?.currency,
              let sourceCurrency = Currency(rawValue: sourceCurrencyValue) else
        {
            return [usd]
        }
        
        return [usd, sourceCurrency]
    }
    
    // Private
    private let accounts: [String : Account] = {
        let accounts = Account.allAccounts(includeHidden: false)
        
        return accounts.reduce([String : Account](), { (dictionary, account) -> [String : Account] in
            var mutableDictionary = dictionary
            
            // TODO: It's possible that accounts have the same display name
            let key = "\(account.sourceInstitutionId) \(account.displayName)"
            mutableDictionary[key] = account
            
            return mutableDictionary
        })
    }()
    
    // MARK: Initialization
    
    internal required init()
    {

    }
    
    // MARK: Account
    
    internal func account(for key: String) -> Account?
    {
        return self.accounts[key]
    }
}
