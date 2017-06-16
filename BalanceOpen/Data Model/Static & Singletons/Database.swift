//
//  Database.swift
//  Bal
//
//  Created by Benjamin Baron on 2/1/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

private class FMDatabasePoolDelegate: NSObject {
    override func databasePool(_ pool: FMDatabasePool!, didAdd db: FMDatabase!) {
        // Decrypt the database
        db.executeStatements("PRAGMA key='\(database.password!)'")
        
        // Enable WAL mode for reads
        db.executeStatements("PRAGMA journal_mode=WAL")
    }
}

class Database {
    
    // MARK: - Properties -
    
    fileprivate let readPoolDelegate = FMDatabasePoolDelegate()
    
    fileprivate static let defaultDatabaseName = "balance.db"
    fileprivate let databaseName: String
    fileprivate let databasePath: String

    /// We're using WAL mode, so only writes need to be serialized. Reads can be multithreaded with no regard for writes.
    let readDbPool: FMDatabasePool
    
    /// Use a database queue to serialize writes. This allows multithreaded access.
    let writeDbQueue: FMDatabaseQueue
    
    fileprivate var password: String? {
        get {
            return keychain[KeychainAccounts.Database, KeychainKeys.Password]
        }
        set {
            keychain[KeychainAccounts.Database, KeychainKeys.Password] = newValue
        }
    }
        
    // MARK: - Lifecycle -
    
    init(databaseName: String = Database.defaultDatabaseName, pathPrefix: String? = nil) {
        let databasePathPrefix = (pathPrefix == nil ? appSupportPathUrl : URL(fileURLWithPath: pathPrefix!))
        let databasePath = databasePathPrefix.appendingPathComponent(databaseName).path
        
        self.databaseName = databaseName
        self.databasePath = databasePath
        
        self.readDbPool = FMDatabasePool(path: databasePath)
        self.writeDbQueue = FMDatabaseQueue(path: databasePath)
    }
    
    func create() {
        // Generate a per-device database password, and store it in the keychain
        if password == nil {
            password = String.random(32)
        }
        
        #if DEBUG
        log.debug("\nsqlcipher \"\(self.databasePath)\" -cmd \"PRAGMA key='\(self.password!)';\"")
        #endif
            
        // Enable WAL mode for writes
        var success = true
        writeDbQueue.inDatabase { db in
            // Decrypt the database
            db.executeStatements("PRAGMA key='\(database.password!)'")
            
            // Enable WAL mode for reads
            success = db.executeStatements("PRAGMA journal_mode=WAL")
            if !success {
                log.severe("Unable to set WAL mode, error: \(db.lastError())")
            }
        }
        
        guard success else {
            log.severe("Resetting database and restarting")
            self.resetDatabase()
            return
        }
        
        // Create default tables if needed
        writeDbQueue.inDatabase { db in
            var statements = [String]()
            
            // source table
            statements.append("CREATE TABLE IF NOT EXISTS sources " +
                              "(sourceId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")
            statements.append("INSERT OR IGNORE INTO sources VALUES (1, \"Plaid\")")
            statements.append("INSERT OR IGNORE INTO sources VALUES (2, \"Coinbase\")")
            statements.append("INSERT OR IGNORE INTO sources VALUES (3, \"Poloniex\")")
            statements.append("INSERT OR IGNORE INTO sources VALUES (4, \"GDAX\")")
            statements.append("INSERT OR IGNORE INTO sources VALUES (5, \"Bitfinex\")")
            
            // institutions table
            statements.append("CREATE TABLE IF NOT EXISTS institutions " +
                              "(institutionId INTEGER PRIMARY KEY AUTOINCREMENT, sourceId INTEGER, sourceInstitutionId TEXT, " +
                              "name TEXT, nameBreak INTEGER, primaryColor TEXT, secondaryColor TEXT, logoData BLOB, passwordInvalid INTEGER, dateAdded INTEGER)")
            statements.append("CREATE INDEX IF NOT EXISTS institutions_sourceIdsourceInstitutionId " +
                              "ON institutions (sourceId, sourceInstitutionId)")
            
            // accountType table
            statements.append("CREATE TABLE IF NOT EXISTS accountTypes " +
                              "(accountTypeId INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")
            
            // account table
            statements.append("CREATE TABLE IF NOT EXISTS accounts " +
                              "(accountId INTEGER PRIMARY KEY AUTOINCREMENT, institutionId INTEGER, sourceId INTEGER, " +
                              "sourceAccountId TEXT, sourceInstitutionId TEXT, accountTypeId INTEGER, accountSubTypeId INTEGER, " +
                              "name TEXT, currency TEXT, decimals INTEGER, currentBalance INTEGER, availableBalance INTEGER, number TEXT)")
            if !db.columnExists("altCurrency", inTableWithName: "accounts") {
                statements.append("ALTER TABLE accounts ADD COLUMN altCurrency TEXT")
                statements.append("ALTER TABLE accounts ADD COLUMN altDecimals INTEGER")
                statements.append("ALTER TABLE accounts ADD COLUMN altCurrentBalance INTEGER")
                statements.append("ALTER TABLE accounts ADD COLUMN altAvailableBalance INTEGER")
            }
 
            for statement in statements {
                if !db.executeUpdate(statement, withArgumentsIn: nil) {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
        }
        
        readDbPool.maximumNumberOfDatabasesToCreate = 20
        readDbPool.delegate = readPoolDelegate
        
        #if DEBUG
        printCompileOptions()
        #endif
    }
    
    // MARK: - Helper -
    
    fileprivate func resetDatabase() {
        writeDbQueue.close()
        readDbPool.releaseAllDatabases()
        do {
            try FileManager.default.removeItem(atPath: databasePath)
            AppDelegate.sharedInstance.relaunch()
        } catch {
            log.severe("Unable to remove database")
        }
    }
    
    fileprivate func printCompileOptions() {
        readDbPool.inDatabase { db in
            do {
                print("Sqlite version \(String(describing: db.stringForQuery("SELECT sqlite_version()"))) compile options:")
                let result = try db.executeQuery("PRAGMA compile_options")
                while result.next() {
                    print("\(result.string(forColumnIndex: 0))")
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
    }
}
