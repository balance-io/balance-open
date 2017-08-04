//
//  AccountsTabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 4/6/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal protocol AccountsTabViewModelDelegate: class
{
    func didClickTransferMenuItem(from source: Account, to recipient: Account)
}


class AccountsTabViewModel: TabViewModel {
    // Internal
    internal weak var delegate: AccountsTabViewModelDelegate?
    
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
        data = Account.accountsByInstitution()
    }
    
    func totalBalance() -> Int {
        var runningTotal: Int = 0
        for institution in data.keys {
            if let accounts = data[institution] {
                for account in accounts {
                    runningTotal = runningTotal + account.displayBalance
                }
            }
        }
        
        return runningTotal
    }
    
    func institutionAdded(institution: Institution) {
        var newData = data
        newData[institution] = Account.accountsForInstitution(institutionId: institution.institutionId)
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
            return $0.sourceId == account.sourceId && $0.sourceInstitutionId == account.sourceInstitutionId
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
    
    // MARK: Menu
    
    internal func menu(forRow row: Int, inSection section: Int) -> NSMenu?
    {
        guard let selectedAccount = self.account(forRow: row, inSection: section) else
        {
            return nil
        }
        
        // Accounts to transfer to
        let transferMenu = NSMenu(title: "Transfer menu")
        
        for (institution, accounts) in self.data.values
        {
            let institutionMenu = NSMenu(title: institution.name)
            
            for account in accounts
            {
                if account == selectedAccount
                {
                    continue
                }
                
                let accountItem = NSMenuItem(title: account.displayName, action: #selector(self.transferToAccountMenuItemClicked(_:)), keyEquivalent: "")
                accountItem.target = self
                
                let transferAction = TransferRequest(sourceAccount: selectedAccount, recipientAccount: account)
                accountItem.representedObject = transferAction
                
                institutionMenu.addItem(accountItem)
            }
            
            let institutionItem = NSMenuItem(title: institution.name, action: nil, keyEquivalent: "")
            institutionItem.submenu = institutionMenu
            transferMenu.addItem(institutionItem)
        }

        let transferToItem = NSMenuItem(title: "Transfer To", action: nil, keyEquivalent: "")
        transferToItem.submenu = transferMenu
        
        let menu = NSMenu(title: "Account menu")
        menu.addItem(transferToItem)
        
        return menu
    }
    
    @objc private func transferToAccountMenuItemClicked(_ sender: Any)
    {
        guard let menuItem = sender as? NSMenuItem,
              let transferAction = menuItem.representedObject as? TransferRequest else
        {
            return
        }
        
        self.delegate?.didClickTransferMenuItem(from: transferAction.sourceAccount, to: transferAction.recipientAccount)
    }
}

// MARK: TransferRequest

fileprivate extension AccountsTabViewModel
{
    fileprivate struct TransferRequest
    {
        fileprivate let sourceAccount: Account
        fileprivate let recipientAccount: Account
    }
}
