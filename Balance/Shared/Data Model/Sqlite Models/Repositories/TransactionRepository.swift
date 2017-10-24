//
//  TransactionRepository.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


/**
 Table Schema
 
 [0] transactionId: INTEGER PRIMARY KEY AUTOINCREMENT
 [1] sourceId: INTEGER
 [2] sourceTransactionId TEXT
 [3] accountId INTEGER
 [4] name TEXT
 [5] currency TEXT
 [6] amount INTEGER
 [7] date REAL
 [8] institutionId INTEGER NOT NULL
 [9] sourceInstitutionId TEXT
 [10] categoryId INTEGER
 */


struct TransactionRepository: ItemRepository {
    static let si = TransactionRepository()
    fileprivate let gr = GenericItemRepository.si
    
    let table = "transactions"
    let itemIdField = "transactionId"
    
    // MARK: Initialization
    
    internal init() {
        self.performMigrations()
    }
    
    // MARK: Migrations
    
    private func performMigrations() {
        // If the app has the old transactions table
        // drop it a build the new one
        database.write.inDatabase { db in
            let result = db.getTableSchema("transactions")
            
            // Old database schema. Update...
            if db.columnExists("address", inTableWithName: "transactions") {
                var statements = [String]()
                statements.append("DROP TABLE IF EXISTS transactions")
                statements.append("CREATE TABLE IF NOT EXISTS transactions (transactionId INTEGER PRIMARY KEY AUTOINCREMENT, sourceId INTEGER, sourceTransactionId TEXT, accountId INTEGER, name TEXT, currency TEXT, amount INTEGER, date REAL, institutionId INTEGER NOT NULL, sourceInstitutionId TEXT, categoryId INTEGER)")
                
                for statement in statements {
                    if !db.executeUpdate(statement, withArgumentsIn: nil) {
                        log.severe("DB Error: " + db.lastErrorMessage())
                    }
                }
            }
            
            result?.close()
        }
    }
    
    // MARK: -
    
    func transaction(transactionId: Int) -> Transaction? {
        var transaction: Transaction?
        database.read.inDatabase { db in
            do {
                let statement = "SELECT transactions.*, accounts.sourceInstitutionId, accounts.institutionId " +
                                "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                                "WHERE transactionId = ?"
                let result = try db.executeQuery(statement, transactionId)
                if result.next() {
                    transaction = Transaction(result: result, repository: self)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        return transaction
    }
    
    @discardableResult func transaction(source: Source, sourceTransactionId: String, sourceAccountId: String, name: String, currency: String, amount: Int, date: Date, categoryID: Int?, institution: Institution) -> Transaction? {
        // First check if a record for this transaction already exists
        var transactionIdFromDb: Int?
        var accountIdFromDb: Int?
        database.read.inDatabase { db in
            do {
                let select = "SELECT transactions.transactionId, transactions.accountId " +
                             "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                             "WHERE transactions.sourceId = ? AND transactions.sourceTransactionId = ? " +
                             "AND accounts.institutionId = ?"
                let result = try db.executeQuery(select, source.rawValue, sourceTransactionId, institution.institutionId)
                if result.next() {
                    transactionIdFromDb = result.object(forColumnIndex: 0) as? Int
                    accountIdFromDb = result.object(forColumnIndex: 1) as? Int
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        if let transactionId = transactionIdFromDb, let accountId = accountIdFromDb {
            let transaction = Transaction(transactionId: transactionId, source: source, sourceTransactionId: sourceTransactionId, sourceAccountId: sourceAccountId, accountId: accountId, name: name, currency: currency, amount: amount, date: date, categoryID: categoryID, institution: institution, repository: self)
            transaction.replace()
            
            return transaction
        } else {
            // No record exists, so this is a new transaction. Insert the record and retrieve the transaction id
            var generatedId: Int?
            database.write.inDatabase { db in
                do {
                    let select = "SELECT accountId FROM accounts WHERE sourceAccountId = ? AND institutionId = ?"
                    let result = try db.executeQuery(select, sourceAccountId, institution.institutionId)
                    if result.next() {
                        accountIdFromDb = result.object(forColumnIndex: 0) as? Int
                    }
                    result.close()
                    
                    if let accountIdFromDb = accountIdFromDb {
                        let insert = "INSERT INTO transactions " +
                                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                        try db.executeUpdate(insert, NSNull(), source.rawValue, sourceTransactionId, accountIdFromDb, name, currency, amount, date, institution.institutionId, institution.sourceInstitutionId, n2N(categoryID))
                        
                        generatedId = Int(db.lastInsertRowId())
                    }
                } catch {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
            
            if let transactionId = generatedId, let accountId = accountIdFromDb {
                let transaction = Transaction(transactionId: transactionId, source: source, sourceTransactionId: sourceTransactionId, sourceAccountId: sourceAccountId, accountId: accountId, name: name, currency: currency, amount: amount, date: date, categoryID: categoryID, institution: institution, repository: self)
                return transaction
            } else {
                // Something went really wrong and we didn't get a transaction id
                // TODO: Handle this error better, this means a serious DB problem
                log.severe("Failed to create transaction record for sourceTransactionId: \(sourceTransactionId)")
                return nil
            }
        }
    }
    
    @discardableResult func deleteAllTransactions() -> Bool {
        return gr.deleteAllItems(repository: self)
    }
    
    func isPersisted(transaction: Transaction) -> Bool {
        return gr.isPersisted(repository: self, item: transaction)
    }
    
    func isPersisted(transactionId: Int) -> Bool {
        return gr.isPersisted(repository: self, itemId: transactionId)
    }
    
    func delete(transaction: Transaction) -> Bool {
        return gr.delete(repository: self, item: transaction)
    }
    
    func transactions(institutionId: Int, includeHidden: Bool = false) -> [Transaction] {
        var transactions = [Transaction]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                var statement = "SELECT transactions.*, accounts.sourceInstitutionId, accounts.institutionId " +
                                "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                                "WHERE accounts.institutionId = ? " +
                                "ORDER BY transactions.date DESC"
                
                let result = try db.executeQuery(statement, institutionId)
                while result.next() {
                    let transaction = Transaction(result: result, repository: self)
                    
                    var belongsToHiddenAccount = false
                    if let accountID = transaction.accountId {
                        belongsToHiddenAccount = hiddenAccountIds.contains(accountID)
                    }
                    
                    if includeHidden || !belongsToHiddenAccount {
                        transactions.append(transaction)
                    }
                }
                result.close()
            } catch {
                log.severe("Error getting transactions for institutionId \(institutionId): " + db.lastErrorMessage())
            }
        }
        
        return transactions
    }
    
    @discardableResult func replace(transaction: Transaction) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let insert = "INSERT OR REPLACE INTO transactions " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                
                // This is a hack to prevent the Swift compiler's random "type inferance takes fucking forever" bug
                // Drops compile time on this function from ~35 seconds to ~5 milliseconds
                let transactionId: Any = transaction.transactionId
                let source: Any = transaction.source.rawValue
                let sourceTransactionId: Any = transaction.sourceTransactionId
                let accountId: Any = n2N(transaction.accountId)
                let name: Any = transaction.name
                let currency: Any = transaction.currency
                let amount: Any = transaction.amount
                let date: Any = transaction.date
                let institutionId: Any = transaction.institutionId
                let sourceInstitutionId: Any = transaction.sourceInstitutionId
                let categoryId: Any = n2N(transaction.categoryId)
                
                try db.executeUpdate(insert, transactionId, source, sourceTransactionId, accountId, name, currency, amount, date, institutionId, sourceInstitutionId, categoryId)
            } catch {
                log.severe("Error replacing transaction \(transaction): " + db.lastErrorMessage())
                success = false
            }
        }
        return success
    }
    
    func oldestTransaction(accountName: String? = nil, includeHidden: Bool = false) -> Transaction? {
        var transaction: Transaction?
        
        database.read.inDatabase { db in
            do {
                var accountNameClause = ""
                var accountNameValue = ""
                if let accountName = accountName {
                    accountNameClause = "accounts.name LIKE ? "
                    accountNameValue = "%\(accountName)%"
                }
                
                var statement = "SELECT transactions.*, accounts.sourceInstitutionId, accounts.institutionId " +
                                "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                                "\(accountNameClause) "
                if !includeHidden {
                    statement += "AND transactions.accountId NOT IN \(defaults.hiddenAccountIdsQuerySet) "
                }
                statement += "ORDER BY date ASC LIMIT 1"
                
                let result = accountName == nil ? try db.executeQuery(statement) : try db.executeQuery(statement, accountNameValue)
                
                if result.next() {
                    transaction = Transaction(result: result, repository: self)
                }
                result.close()
            } catch {
                log.severe("Error getting oldest transaction: " + db.lastErrorMessage())
            }
        }
        
        return transaction
    }
    
    func transactionsByDate(includeHidden: Bool = false) -> (transactions: OrderedDictionary<Date, [Transaction]>, counts: [Int]) {
        var transactionsByDate = OrderedDictionary<Date, [Transaction]>()
        var counts = [Int]()
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                let statement = "SELECT transactions.*, accounts.sourceInstitutionId, accounts.institutionId " +
                                "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                                "ORDER BY transactions.date DESC"
                let result = try db.executeQuery(statement)
                
                var firstRow = true
                var previousDate = Date.distantFuture
                var transactions = [Transaction]()
                let calendar = Calendar.current
                
                while result.next() {
                    // Process the transaction
                    let transaction = Transaction(result: result, repository: self)
                    
                    var belongsToHiddenAccount = false
                    if let accountID = transaction.accountId {
                        belongsToHiddenAccount = hiddenAccountIds.contains(accountID)
                    }
                    
                    if includeHidden || !belongsToHiddenAccount {
                        // Setup the dictionary key if first row
                        if firstRow {
                            previousDate = transaction.date
                            firstRow = false
                        }
                        
                        // If dates don't match, store the previous transactions in the dictionary
                        if !calendar.isDate(previousDate, inSameDayAs: transaction.date) {
                            transactionsByDate[previousDate] = transactions
                            counts.append(transactions.count)
                            transactions = [Transaction]()
                            previousDate = transaction.date
                        }
                        
                        // Append this transaction
                        transactions.append(transaction)
                    }
                }
                result.close()
                
                // Insert the late date section
                if transactions.count > 0 {
                    transactionsByDate[previousDate] = transactions
                    counts.append(transactions.count)
                }
            } catch {
                log.severe("Error getting transactions by date: " + db.lastErrorMessage())
            }
        }
        
        return (transactionsByDate, counts)
    }
    
    // Returns an array of transactions where a similarly named transaction does not exist before startDate
    func transactionsFromNewMerchantsInDateRange(_ startDate: Date, endDate: Date, includeHidden: Bool = false) -> [Transaction] {
        var transactions = [Transaction]()
        
        let exceptions = ["uber"]
        
        let hiddenAccountIds = defaults.hiddenAccountIds
        
        database.read.inDatabase { db in
            do {
                let dateSql = "DATE(?, 'unixepoch', 'localtime')"
                let statement = "SELECT transactions.*, accounts.sourceInstitutionId, accounts.institutionId " +
                                "FROM transactions LEFT JOIN accounts ON transactions.accountId = accounts.accountId " +
                                "WHERE DATE(date, 'unixepoch', 'localtime') BETWEEN \(dateSql) AND \(dateSql) " +
                                "AND SOUNDEX(transactions.name) NOT IN (SELECT SOUNDEX(transactions.name) FROM transactions WHERE DATE(date, 'unixepoch', 'localtime') < \(dateSql))"
                let result = try db.executeQuery(statement, startDate.timeIntervalSince1970, endDate.timeIntervalSince1970, startDate.timeIntervalSince1970)
                while result.next() {
                    let transaction = Transaction(result: result, repository: self)
                    
                    var belongsToHiddenAccount = false
                    if let accountID = transaction.accountId {
                        belongsToHiddenAccount = hiddenAccountIds.contains(accountID)
                    }
                    
                    if includeHidden || !belongsToHiddenAccount {
                        transactions.append(transaction)
                    }
                }
                result.close()
                
                for transaction in transactions {
                    for exception in exceptions {
                        if transaction.name.lowercased().contains(exception) {
                            let statement = "SELECT count(name) " +
                                            "FROM transactions " +
                                            "WHERE DATE(date, 'unixepoch', 'localtime') < \(dateSql) AND name LIKE '%\(exception)%'"
                            let count = db.intForQuery(statement, startDate.timeIntervalSince1970)
                            
                            if count > 0, let index = transactions.index(of: transaction) {
                                transactions.remove(at: index)
                            }
                        }
                    }
                }
            } catch {
                log.severe("Error getting transactions from new merchants in date range: " + db.lastErrorMessage())
            }
        }
        
        return transactions
    }
    
    // Returns an absolute value
    func minTransactionAmount(includeHidden: Bool = false) -> Int {
        var minTransactionAmount = 0
        database.read.inDatabase { db in
            var statement = "SELECT MIN(ABS(amount)) FROM transactions"
            if !includeHidden {
                statement += " WHERE transactions.accountId NOT IN \(defaults.hiddenAccountIdsQuerySet)"
            }
            minTransactionAmount = db.intForQuery(statement)
        }
        return minTransactionAmount
    }
    
    // Returns an absolute value
    func maxTransactionAmount(includeHidden: Bool = false) -> Int {
        var maxTransactionAmount = 0
        database.read.inDatabase { db in
            var statement = "SELECT MAX(ABS(amount)) FROM transactions"
            if !includeHidden {
                statement += " WHERE transactions.accountId NOT IN \(defaults.hiddenAccountIdsQuerySet)"
            }
            maxTransactionAmount = db.intForQuery(statement)
        }
        return maxTransactionAmount
    }
    
    var maxTransactionId: Int {
        get {
            var maxTransactionId = 0
            database.read.inDatabase { db in
                maxTransactionId = db.intForQuery("SELECT MAX(transactionId) FROM transactions")
            }
            return maxTransactionId
        }
    }
}

extension Transaction: PersistedItem {
    class func item(itemId: Int, repository: ItemRepository = TransactionRepository.si) -> Item? {
        return (repository as? TransactionRepository)?.transaction(transactionId: itemId)
    }
    
    var isPersisted: Bool {
        return repository.isPersisted(transaction: self)
    }
    
    @discardableResult func replace() -> Bool {
        return repository.replace(transaction: self)
    }
    
    @discardableResult func delete() -> Bool {
        return repository.delete(transaction: self)
    }
}
