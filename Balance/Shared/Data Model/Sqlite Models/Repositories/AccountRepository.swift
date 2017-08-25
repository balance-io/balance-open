//
//  AccountRepository.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct AccountRepository: ItemRepository {
    static let si = AccountRepository()
    fileprivate let gr = GenericItemRepository.si
    
    let table = "accounts"
    let itemIdField = "accountId"
    
    func account(accountId: Int) -> Account? {
        return gr.item(repository: self, itemId: accountId)
    }
    
    @discardableResult func account(institutionId: Int, source: Source, sourceAccountId: String, sourceInstitutionId: String, accountTypeId: AccountType, accountSubTypeId: AccountType?, name: String, currency: String, currentBalance: Int, availableBalance: Int?, number: String?, altCurrency: String? = nil, altCurrentBalance: Int? = nil, altAvailableBalance: Int? = nil) -> Account? {
        // First check if a record for this account already exists
        var accountIdFromDb: Int?
        database.read.inDatabase { db in
            let select = "SELECT accountId FROM accounts WHERE sourceId = ? AND sourceAccountId = ? AND institutionId = ?"
            if let accountIdString = db.stringForQuery(select, source.rawValue, sourceAccountId, institutionId) {
                // Record exists, so use the account id from the database
                accountIdFromDb = (accountIdString as NSString).integerValue
            }
        }
        
        if let accountId = accountIdFromDb {
            let account = Account(accountId: accountId, institutionId: institutionId, source: source, sourceAccountId: sourceAccountId, sourceInstitutionId: sourceInstitutionId, accountTypeId: accountTypeId, accountSubTypeId: accountSubTypeId, name: name, currency: currency, currentBalance: currentBalance, availableBalance: availableBalance, number: number, altCurrency: altCurrency, altCurrentBalance: altCurrentBalance, altAvailableBalance: altAvailableBalance)
            account.replace()
            return account
        } else {
            // No record exists, so this is a new account. Insert the record and retrieve the account id
            var generatedId: Int?
            database.write.inDatabase { db in
                do {
                    let insert = "INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    try db.executeUpdate(insert, NSNull(), institutionId, source.rawValue, sourceAccountId, sourceInstitutionId, accountTypeId.rawValue, n2N(accountSubTypeId?.rawValue), name, currency, currentBalance, n2N(availableBalance), n2N(number), n2N(altCurrency), n2N(altCurrentBalance), n2N(altAvailableBalance))
                    
                    generatedId = Int(db.lastInsertRowId())
                } catch {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
            
            if let accountId = generatedId {
                let account = self.account(accountId: accountId)
                return account
            } else {
                // TODO: Handle this error better, this means a serious DB problem
                // Something went really wrong and we didn't get an accountId id
                log.severe("Failed to create accountId for account type \(accountTypeId)")
                return nil
            }
        }
    }
    
    func allAccounts(includeHidden: Bool = false) -> [Account] {
        var accounts = [Account]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts ORDER BY institutionId, name"
                let result = try db.executeQuery(statement)
                while result.next() {
                    let account = Account(result: result, repository: self)
                    if includeHidden || !hiddenAccountIds.contains(account.accountId) {
                        accounts.append(account)
                    }
                }
                result.close()
            } catch {
                log.severe("Error loading all accounts: " + db.lastErrorMessage())
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        return accounts
    }
    
    func accountsByInstitution(includeHidden: Bool = false) -> OrderedDictionary<Institution, [Account]> {
        var accountsByInstitutionId = [Int: [Account]]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts ORDER BY institutionId, name"
                let result = try db.executeQuery(statement)
                
                while result.next() {
                    let account = Account(result: result, repository: self)
                    if includeHidden || !hiddenAccountIds.contains(account.accountId) {
                        if var accounts = accountsByInstitutionId[account.institutionId] {
                            accounts.append(account)
                            accountsByInstitutionId[account.institutionId] = accounts
                        } else {
                            accountsByInstitutionId[account.institutionId] = [account]
                        }
                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        var dbData = OrderedDictionary<Institution, [Account]>()
        let institutions = InstitutionRepository.si.allInstitutions()
        for institution in institutions {
            dbData[institution] = accountsByInstitutionId[institution.institutionId] ?? [Account]()
        }
        
        if let institutionsOrder = defaults.accountsViewInstitutionsOrder, let accountsOrder = defaults.accountsViewAccountsOrder {
            // Sort the institutions
            var unsortedInstitutions = dbData.keys
            var institutions = [Institution]()
            
            // For each sorted institution id, find the corresponding institution
            for institutionId in institutionsOrder {
                if let index = unsortedInstitutions.index(where: {$0.institutionId == institutionId}) {
                    let institution = unsortedInstitutions[index]
                    institutions.append(institution)
                    unsortedInstitutions.remove(at: index)
                }
            }
            
            // Append any remaining ones to the end
            institutions.append(contentsOf: unsortedInstitutions)
            
            // Create a sorted dictionary using these institutions
            var sortedData = OrderedDictionary<Institution, [Account]>()
            sortedData.keys = institutions
            
            // Sort the accounts
            for institutionId in accountsOrder.keys {
                if let index = dbData.keys.index(where: {$0.institutionId == institutionId}) {
                    // Find the institution for each institution id and it's unsorted accounts
                    let institution = dbData.keys[index]
                    var unsortedAccounts = dbData[institution]!
                    var accounts = [Account]()
                    
                    // For each sorted account id, find the corresponding account
                    for accountId in accountsOrder[institutionId]! {
                        if let index = unsortedAccounts.index(where: {$0.accountId == accountId}) {
                            let account = unsortedAccounts[index]
                            accounts.append(account)
                            unsortedAccounts.remove(at: index)
                        }
                    }
                    
                    // Append any remaining ones to the end
                    accounts.append(contentsOf: unsortedAccounts)
                    
                    // Update the sorted dictionary
                    sortedData.values[institution] = accounts
                }
            }
            
            // Add accounts without sort info
            for institution in sortedData.keys {
                if sortedData.values[institution] == nil {
                    sortedData.values[institution] = dbData[institution]
                }
            }
            
            // Use the sorted data
            return sortedData
        } else {
            // Use unsorted data
            return dbData
        }
    }
    
    func isPersisted(account: Account) -> Bool {
        return gr.isPersisted(repository: self, item: account)
    }
    
    func isPersisted(accountId: Int) -> Bool {
        return gr.isPersisted(repository: self, itemId: accountId)
    }
    
    func accounts(institutionId: Int, includeHidden: Bool = false) -> [Account] {
        var accounts = [Account]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts WHERE institutionId = ? ORDER BY name"
                let result = try db.executeQuery(statement, institutionId)
                while result.next() {
                    let account = Account(result: result, repository: self)
                    if includeHidden || !hiddenAccountIds.contains(account.accountId) {
                        accounts.append(account)
                    }
                }
                result.close()
            } catch {
                log.severe("Error loading accounts for institutionId \(institutionId): " + db.lastErrorMessage())
            }
        }
        
        return accounts
    }
    
    @discardableResult func replace(account: Account) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let insert = "INSERT OR REPLACE INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                
                // Hack for compile time speed
                let accountId: Any = account.accountId
                let institutionId: Any = account.institutionId
                let sourceId: Any = account.source.rawValue
                let sourceAccountId: Any = account.sourceAccountId
                let sourceInstitutionId: Any = account.sourceInstitutionId
                let accountType: Any = account.accountType.rawValue
                let accountSubType: Any = n2N(account.accountSubType?.rawValue)
                let name: Any = account.name
                let currency: Any = account.currency
                let currentBalance: Any = account.currentBalance
                let availableBalance: Any = n2N(account.availableBalance)
                let number: Any = n2N(account.number)
                let altCurrency: Any = n2N(account.altCurrency)
                let altCurrentBalance: Any = n2N(account.altCurrentBalance)
                let altAvailableBalance: Any = n2N(account.altAvailableBalance)
                
                try db.executeUpdate(insert, accountId, institutionId, sourceId, sourceAccountId, sourceInstitutionId, accountType, accountSubType, name, currency, currentBalance, availableBalance, number, altCurrency, altCurrentBalance, altAvailableBalance)
            } catch {
                log.severe("Error replacing account \(account): " + db.lastErrorMessage())
                success = false
            }
        }
        return success
    }
    
    @discardableResult func delete(account: Account) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                // Begin transaction
                try db.executeUpdate("BEGIN")
                
                // Delete transaction records
                let statement1 = "DELETE FROM transactions WHERE accountId = ?"
                try db.executeUpdate(statement1, account.accountId)
                
                // Delete account records
                let statement2 = "DELETE FROM accounts WHERE accountId = ?"
                try db.executeUpdate(statement2, account.accountId)
                
                // End transaction
                try db.executeUpdate("COMMIT")
            } catch {
                log.severe("Error removing account \(account):" + db.lastErrorMessage())
                success = false
            }
        }
        
        if success {
            let userInfo = Notifications.userInfoForAccount(account)
            NotificationCenter.postOnMainThread(name: Notifications.AccountRemoved, object: nil, userInfo: userInfo)
        }
        
        return success
    }
    
    @discardableResult func delete(accountId: Int) -> Bool {
        if let account = account(accountId: accountId) {
            return delete(account: account)
        }
        return false
    }
}

extension Account: PersistedItem {
    class func item(itemId: Int, repository: ItemRepository = AccountRepository.si) -> Item? {
        return (repository as? AccountRepository)?.account(accountId: itemId)
    }
    
    var isPersisted: Bool {
        return repository.isPersisted(account: self)
    }
    
    @discardableResult func replace() -> Bool {
        return repository.replace(account: self)
    }
    
    @discardableResult func delete() -> Bool {
        return repository.delete(account: self)
    }
}

extension Account {
    var numberOfTransactions: Int {
        var numberOfTransactions = 0
        database.read.inDatabase { db in
            let statement = "SELECT COUNT(*) FROM transactions WHERE accountId = ?"
            numberOfTransactions = db.intForQuery(statement, self.accountId)
        }
        
        return numberOfTransactions
    }
    
    var oldestTransactionDate: Date? {
        var date: Date?
        database.read.inDatabase { db in
            let statement = "SELECT date FROM transactions WHERE accountId = ? ORDER BY date ASC LIMIT 1"
            date = db.dateForQuery(statement, self.accountId)
        }
        
        return date
    }
}
