//
//  InstitutionSettingsViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


final class InstitutionSettingsViewModel
{
    // Internal
    var numberOfAccounts: Int {
        return self.accounts.count
    }
    
    // Private
    private let institution: Institution
    private var accounts: [Account]
    
    // MARK: Initialization
    
    required init(institution: Institution)
    {
        self.institution = institution
        self.accounts = AccountRepository.si.accounts(institutionId: institution.institutionId, includeHidden: true)
    }
    
    // MARK: Accounts
    
    func account(at index: Int) -> Account
    {
        return self.accounts[index]
    }
    
    func set(account: Account, hidden: Bool)
    {
        account.isHidden = hidden
    }
}
