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
    
    internal let accountNames: [String]
    
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
    private let accounts: [Account] = Account.allAccounts(includeHidden: false)
    
    // MARK: Initialization
    
    internal required init()
    {
        self.accountNames = self.accounts.map({ (account) -> String in
            guard let institutionName = account.institution?.name else
            {
                return account.displayName
            }
            
            return "\(institutionName): \(account.displayName)"
        })
    }
    
    // MARK: Account
    
    internal func account(at index: Int) -> Account
    {
        return self.accounts[index]
    }
    
    internal func index(of account: Account) -> Int?
    {
        return self.accounts.index(of: account)
    }
}
