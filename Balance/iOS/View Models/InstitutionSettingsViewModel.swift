//
//  InstitutionSettingsViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class InstitutionSettingsViewModel
{
    // Internal
    internal var numberOfAccounts: Int {
        return self.accounts.count
    }
    
    // Private
    private let institution: Institution
    private var accounts: [Account]
    
    // MARK: Initialization
    
    internal required init(institution: Institution)
    {
        self.institution = institution
        self.accounts = AccountRepository.si.accounts(institutionId: institution.institutionId, includeHidden: true)
    }
    
    // MARK: Accounts
    
    internal func account(at index: Int) -> Account
    {
        return self.accounts[index]
    }
    
    internal func set(account: Account, hidden: Bool)
    {
        account.isHidden = hidden
    }
}
