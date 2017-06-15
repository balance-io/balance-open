//
//  Account.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.accountId == rhs.accountId
}

private func arrayFromResult(_ result: FMResultSet) -> [AnyObject] {
    var array = [AnyObject]()
    
    array.append(result.long(forColumnIndex: 0) as AnyObject)                      // accountId
    array.append(result.long(forColumnIndex: 1) as AnyObject)                      // sourceId
    array.append(result.string(forColumnIndex: 2) as AnyObject)                    // sourceAccountId
    array.append(result.string(forColumnIndex: 3) as AnyObject)                    // sourceInstitutionId
    array.append(result.long(forColumnIndex: 4) as AnyObject)                      // accountType
    array.append(n2N(result.object(forColumnIndex: 5) as? Int) as AnyObject)       // accountSubType
    
    array.append(result.string(forColumnIndex: 6) as AnyObject)                    // name
    
    array.append(result.long(forColumnIndex: 7) as AnyObject)                      // currentBalance
    array.append(n2N(result.object(forColumnIndex: 8) as? Int))       // availableBalance
    
    array.append(n2N(result.object(forColumnIndex: 9) as? String))    // number
    
    array.append(n2N(result.object(forColumnIndex: 10) as? Int))      // institutionId
    
    return array
}

class Account: Equatable {
    
    var accountId: Int
    var institutionId: Int
    var sourceId: Source
    var sourceAccountId: String
    var sourceInstitutionId: String
    var accountType: AccountType
    var accountSubType: AccountType?
    
    var name: String
    
    var currentBalance: Int
    var availableBalance: Int?
    
    // Last 4 digits of credit card number, if applicable, using String as Plaid uses that format in JSON
    var number: String?
    
    var isCreditAccount: Bool {
        // Assume a balance is positive.
        // If there is a bug, it is better for them not to suffer the heart attack of positive balances displaying as negative.
        var isCreditAccount = false
        
        // While credit accounts should be negative
        if accountType == .credit ||
            accountType == .loan ||
            accountType == .mortgage {
            isCreditAccount = true
        }
        
        // Same for the sub types
        if let accountSubType = accountSubType {
            if accountSubType == .checking ||
                accountSubType == .savings ||
                accountSubType == .prepaid ||
                accountSubType == .cashManagement ||
                accountSubType == .ira ||
                accountSubType == .cd ||
                accountSubType == .certificateOfDeposit ||
                accountSubType == .mutualFund {
                isCreditAccount = false
            }
            
            if accountSubType == .creditCard ||
                accountSubType == .lineOfCredit ||
                accountSubType == .auto ||
                accountSubType == .home ||
                accountSubType == .installment {
                isCreditAccount = true
            }
        }
        
        return isCreditAccount
    }
    
    var displayBalance: Int {
        if isCreditAccount {
            // Show negative balance for credit accounts
            return -currentBalance
        } else {
            // For deposit accounts, show the available balance if possible
            return availableBalance ?? currentBalance
        }
    }
    
    var numberOfTransactions: Int {
        var numberOfTransactions = 0
        database.readDbPool.inDatabase { db in
            let statement = "SELECT COUNT(*) FROM transactions WHERE accountId = ?"
            numberOfTransactions = db.longForQuery(statement, self.accountId)
        }
        
        return numberOfTransactions
    }
    
    var oldestTransactionDate: Date? {
        var date: Date?
        database.readDbPool.inDatabase { db in
            let statement = "SELECT date FROM transactions WHERE accountId = ? ORDER BY date ASC LIMIT 1"
            date = db.dateForQuery(statement, self.accountId)
        }
        
        return date
    }
    
    var displayName: String {
        return name.capitalizedStringIfAllCaps
    }
    
    var institution: Institution? {
        return Institution(institutionId: institutionId)
    }
    
    var passwordInvalid: Bool {
        if let institution = self.institution {
            return institution.passwordInvalid
        }
        return false
    }
    
    convenience init?(accountId: Int) {
        var resultArray: [AnyObject]?
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts WHERE accountId = ?"
                let result = try db.executeQuery(statement, accountId)
                if result.next() {
                    resultArray = arrayFromResult(result)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        if let resultArray = resultArray {
            self.init(resultArray)
        } else {
            return nil
        }
    }
    
    init(_ resultArray: [AnyObject]) {
        self.accountId = resultArray[0] as! Int
        self.sourceId = Source(rawValue: resultArray[1] as! Int)!
        self.sourceAccountId = resultArray[2] as! String
        self.sourceInstitutionId = resultArray[3] as! String
        self.accountType = AccountType(rawValue: resultArray[4] as! Int)!
        let subType = resultArray[5] as? Int
        self.accountSubType = subType == nil ? nil : AccountType(rawValue: subType!)
        
        self.name = resultArray[6] as! String
        
        self.currentBalance = resultArray[7] as! Int
        self.availableBalance = resultArray[8] as? Int
        
        self.number = resultArray[9] as? String
        
        self.institutionId = resultArray[10] as! Int
    }
    
    init?(institutionId: Int, sourceId: Source, sourceAccountId: String, sourceInstitutionId: String, accountTypeId: AccountType, accountSubTypeId: AccountType?, name: String, currentBalance: Int, availableBalance: Int?, number: String?) {
        
        self.institutionId = institutionId
        self.sourceId = sourceId
        self.sourceAccountId = sourceAccountId
        self.sourceInstitutionId = sourceInstitutionId
        self.accountType = accountTypeId
        self.accountSubType = accountSubTypeId
        
        self.name = name
        
        self.currentBalance = currentBalance
        self.availableBalance = availableBalance
        
        self.number = number
        
        // First check if a record for this account already exists
        var accountIdFromDb: Int?
        database.readDbPool.inDatabase { db in
            let select = "SELECT accountId FROM accounts WHERE sourceId = ? AND sourceAccountId = ? AND institutionId = ?"
            if let accountIdString = db.stringForQuery(select, sourceId.rawValue, sourceAccountId, institutionId) {
                // Record exists, so use the account id from the database
                accountIdFromDb = (accountIdString as NSString).integerValue
            }
        }
        
        if let accountId = accountIdFromDb {
            self.accountId = accountId
            self.updateModel()
        } else {
            // No record exists, so this is a new account. Insert the record and retrieve the account id
            var generatedId: Int?
            database.writeDbQueue.inDatabase { db in
                do {
                    let insert = "INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    try db.executeUpdate(insert, NSNull(), sourceId.rawValue, sourceAccountId, sourceInstitutionId, accountTypeId.rawValue, n2N(accountSubTypeId?.rawValue), name, currentBalance, n2N(availableBalance), n2N(number), institutionId)
                    
                    generatedId = Int(db.lastInsertRowId())
                } catch {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
            
            if let accountId = generatedId {
                self.accountId = accountId
            } else {
                // TODO: Handle this error better, this means a serious DB problem
                // Something went really wrong and we didn't get an accountId id
                log.severe("Failed to create accountId for account type \(accountTypeId)")
                return nil
            }
        }
    }
    
    // Update an existing model
    func updateModel() {
        database.writeDbQueue.inDatabase { db in
            do {
                let insert = "INSERT OR REPLACE INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                
                // Hack for compile time speed
                let accountId: Any = self.accountId
                let sourceId: Any = self.sourceId.rawValue
                let sourceAccountId: Any = self.sourceAccountId
                let sourceInstitutionId: Any = self.sourceInstitutionId
                let accountType: Any = self.accountType.rawValue
                let accountSubType: Any = n2N(self.accountSubType?.rawValue)
                let name: Any = self.name
                let currentBalance: Any = self.currentBalance
                let availableBalance: Any = n2N(self.availableBalance)
                let number: Any = n2N(self.number)
                let institutionId: Any = self.institutionId
                
                try db.executeUpdate(insert, accountId, sourceId, sourceAccountId, sourceInstitutionId, accountType, accountSubType, name, currentBalance, availableBalance, number, institutionId)
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
    }
    
    static func allAccounts(includeHidden: Bool = false) -> [Account] {
        var accounts = [Account]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts ORDER BY institutionId, name"
                let result = try db.executeQuery(statement)
                while result.next() {
                    let resultArray = arrayFromResult(result)
                    let account = Account(resultArray)
                    if includeHidden || !hiddenAccountIds.contains(account.accountId) {
                        accounts.append(Account(resultArray))
                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        return accounts
    }
    
    static func accountsByInstitution(includeHidden: Bool = false) -> OrderedDictionary<Institution, [Account]> {
        var accountsByInstitutionId = [Int: [Account]]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts ORDER BY institutionId, name"
                let result = try db.executeQuery(statement)
                
                while result.next() {
                    let resultArray = arrayFromResult(result)
                    let account = Account(resultArray)
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
        let institutions = Institution.allInstitutions()
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
    
    static func accountsForInstitution(institutionId: Int, includeHidden: Bool = false) -> [Account] {
        var accounts = [Account]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM accounts WHERE institutionId = ? ORDER BY name"
                let result = try db.executeQuery(statement, institutionId)
                while result.next() {
                    let resultArray = arrayFromResult(result)
                    let account = Account(resultArray)
                    if includeHidden || !hiddenAccountIds.contains(account.accountId) {
                        accounts.append(Account(resultArray))
                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        return accounts
    }
    
    static func removeAccount(accountId: Int) {
        if let account = Account(accountId: accountId) {
            database.writeDbQueue.inDatabase { db in
                do {
                    // Begin transaction
                    try db.executeUpdate("BEGIN")
                    
                    // Delete account records
                    let statement2 = "DELETE FROM accounts WHERE accountId = ?"
                    try db.executeUpdate(statement2, accountId)
                    
                    // End transaction
                    try db.executeUpdate("COMMIT")
                } catch {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
            
            let userInfo = Notifications.userInfoForAccount(account)
            NotificationCenter.postOnMainThread(name: Notifications.AccountRemoved, object: nil, userInfo: userInfo)
        }
    }
}

extension Account: CustomStringConvertible {
    var description: String {
        return "\(accountId): \(name)"
    }
}
