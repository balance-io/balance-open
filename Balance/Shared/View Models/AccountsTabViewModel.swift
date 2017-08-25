//
//  AccountsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 4/6/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class AccountsTabViewModel: TabViewModel {
    
    // MARK: Table Data
    var data = OrderedDictionary<Institution, [Account]>()
    
    func persistSortOrder() {
        // Institutions
        defaults.accountsViewInstitutionsOrder = data.keys.map({$0.institutionId})
        
        // Accounts
        var sortOrder = [Int: [Int]]()
        for institution in data.keys {
            var accountIds = [Int]()
            if let accounts = data[institution] {
                for account in accounts {
                    accountIds.append(account.accountId)
                }
                sortOrder[institution.institutionId] = accountIds
            }
        }
        defaults.accountsViewAccountsOrder = sortOrder
    }
    
    func reloadData() {
        // Load the sort order
        data = AccountRepository.si.accountsByInstitution()
    }
    
    func totalBalance() -> Int {
        let excludedAccountIds = defaults.accountIdsExcludedFromTotal
        
        var runningTotal: Int = 0
        for institution in data.keys {
            if let accounts = data[institution] {
                for account in accounts {
                    if !excludedAccountIds.contains(account.accountId) {
                        runningTotal = runningTotal + account.displayBalance
                    }
                }
            }
        }
        
        return runningTotal
    }
    
    func institutionAdded(institution: Institution) {
        var newData = data
        newData[institution] = AccountRepository.si.accounts(institutionId: institution.institutionId)
        data = newData
        persistSortOrder()
    }
    
    func institutionRemoved(institution: Institution) {
        var newData = data
        newData[institution] = nil
        data = newData
        persistSortOrder()
    }
    
    func accountRemoved(account: Account) {
        let oldData = data
        var newData = data
        
        let index = oldData.keys.index {
            return $0.source == account.source && $0.sourceInstitutionId == account.sourceInstitutionId
        }
        
        // Remove the account
        if let index = index {
            let existingInstitution = oldData.keys[index]
            if let existingAccounts = oldData[existingInstitution] {
                var remainingAccounts = existingAccounts
                for existingAccount in existingAccounts {
                    if existingAccount.accountId == account.accountId, let accountIndex = remainingAccounts.index(of: account) {
                        remainingAccounts.remove(at: accountIndex)
                        break
                    }
                }
                
                newData[existingInstitution] = remainingAccounts
            }
        }
        
        data = newData
        persistSortOrder()
    }
    
    func numberOfSections() -> Int {
        return data.count
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        if data.count > section, let accounts = data[section] {
            return accounts.count
        }
        return 0
    }
    
    func institution(forSection section: Int) -> Institution? {
        if data.keys.count > section {
            let institution = data.keys[section]
            return institution
        }
        return nil
    }
    
    func account(forRow row: Int, inSection section: Int) -> Account? {
        if let sectionData = data[section], sectionData.count > row {
            let account = sectionData[row]
            return account
        }
        return nil
    }
}
