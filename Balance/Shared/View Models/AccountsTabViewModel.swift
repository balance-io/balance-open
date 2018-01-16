//
//  AccountsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 4/6/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class AccountsTabViewModel: TabViewModel {
    // MARK: Formatted values
    internal var formattedMasterCurrencyTotalBalance: String {
        return amountToString(amount: totalBalance(), currency: defaults.masterCurrency, showNegative: true, showCodeAfterValue: true)
    }
    
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
                        runningTotal = runningTotal + (account.displayAltBalance ?? 0)
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
    
    func removeInstitution(at index: Int) -> Bool {
        guard let institution = institution(forSection: index) else {
            return false
        }
        
        guard institution.delete() else {
            log.error("Intitution with \(institution.institutionId) id, can't be deleted")
            return false
        }
        
        InstitutionRepository.si.removeUnSelectedCards(with: [institution.institutionId])
        institutionRemoved(institution: institution)
        
        return true
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
        if section >= 0, data.count > section, let accounts = data[section] {
            return accounts.count
        }
        return 0
    }
    
    func isLastRow(_ row: Int, inSection section: Int) -> Bool {
        return row == numberOfRows(inSection: section) - 1
    }
    
    func institution(forSection section: Int) -> Institution? {
        if section >= 0, data.keys.count > section {
            let institution = data.keys[section]
            return institution
        }
        return nil
    }
    
    func account(forRow row: Int, inSection section: Int) -> Account? {
        if section >= 0, row >= 0, let sectionData = data[section], sectionData.count > row {
            let account = sectionData[row]
            return account
        }
        return nil
    }
}

//mark: Selected Cards Methods
extension AccountsTabViewModel {
    
    var selectedCardIndexes: [IndexPath] {
        let availableInstitutionIds = data.keys.map { $0.institutionId }
        let availableInstitutionIdsSet = Set(availableInstitutionIds)
        let savedInstitutionIdsSet = Set(InstitutionRepository.si.selectedCards)
        let institutionIdsToRemove =  savedInstitutionIdsSet.subtracting(availableInstitutionIdsSet)
        
        guard !availableInstitutionIdsSet.isEmpty,
            !savedInstitutionIdsSet.isEmpty else {
                InstitutionRepository.si.removeUnSelectedCards()
                return []
        }
        
        if !institutionIdsToRemove.isEmpty {
            InstitutionRepository.si.removeUnSelectedCards(with: Array(institutionIdsToRemove))
        }
        
        let institutionIdsTrasformed = savedInstitutionIdsSet
            .intersection(availableInstitutionIdsSet)
            .flatMap { availableInstitutionIds.index(of: $0) }
            .map { IndexPath(item: $0, section: 0) }
        
        return institutionIdsTrasformed
    }
    
    func updateSelectedCards(with selection: [IndexPath]) {
        let institutionsIds = data.keys.map { $0.institutionId }
        let institutionsIdsWithIndexes = institutionsIds.enumerated().map { $0 }
        let validInstitutions = institutionsIdsWithIndexes.filter {
            (offset, id) in
            return selection.contains(where: { (indexpath) -> Bool in
                return indexpath.row == offset
            })
        }
        
        InstitutionRepository.si.saveSelectedCards(validInstitutions.map { $0.element })
    }
    
}
