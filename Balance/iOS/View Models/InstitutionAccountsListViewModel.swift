//
//  InstitutionAccountsListViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class InstitutionAccountsListViewModel {
    // Internal
    internal let institution: Institution
    
    internal var numberOfAccounts: Int {
        return self.accounts.count
    }
    
    // Private
    private var accounts = [Account]()
    
    // MARK: Initialization
    
    internal required init(institution: Institution) {
        self.institution = institution
        self.reloadData()
    }
    
    // MARK: Data
    
    private func reloadData() {
        self.accounts = AccountRepository.si.accounts(institutionId: self.institution.institutionId)
    }
    
    // MARK: API
    
    internal func account(at index: Int) -> Account {
        return self.accounts[index]
    }
}
