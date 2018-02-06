//
//  AccountsListViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 11/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

final class AccountsListViewModel {
    var institution: Institution
    
    var numberOfAccounts: Int {
        return accounts.count
    }
    
    // Private
    private var accounts = [Account]()
    
    // MARK: Initialization
    
    required init(institution: Institution) {
        self.institution = institution
        self.reloadData()
    }
    
    // MARK: Data
    
    private func reloadData() {
        accounts = AccountRepository.si.accounts(institutionId: self.institution.institutionId)
    }
    
    // MARK: API
    
    func account(at index: Int) -> Account {
        return accounts[index]
    }
}
