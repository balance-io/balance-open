//
//  Testing.swift
//  Bal
//
//  Created by Benjamin Baron on 9/11/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

private func env(_ key: String) -> Bool {
    return ProcessInfo.processInfo.environment[key] != nil
}

struct Testing {
    static let excludedAccountIds: [Int] = [6, 2, 4]
    static let accountsViewInstitutionsOrder: [Int] = [Int]()//[String] = ["chase", "5886", "amex", "7298", "30671", "1407", "30729"]
    static let accountsViewAccountsOrder: [Int: [Int]] = [Int: [Int]]()//[String: [Int]] = ["30671": [8], "1407": [9], "chase": [1], "5886": [4, 2, 3], "30729": [10], "7298": [7], "amex": [6, 5]]
    static var _defaults: Defaults? = nil
    
    static var runningTests: Bool {
        return runningUiTests || runningUnitTests
    }
    
    static var runningUiTests: Bool {
        return env("RUNNING_UI_TESTS")
    }
    
    static var runningUnitTests: Bool {
        return NSClassFromString("XCTest") != nil
    }
    
    static var useCleanDb: Bool {
        return env("USE_CLEAN_DB")
    }
    
    static var defaults: Defaults {
        if _defaults == nil {
            _defaults = MockedDefaults(defaults: MockedDefaultsStorage())
            
            if runningUiTests {
                copyUserDefaults()
            }
        }
        
        return _defaults!
    }
    
    static var database: Database {
        // If we're in test mode, we want to reset the database every time the application launches,
        // so we need to copy the DB from the bundle and then return an appropriate instance of Database()
        copyDatabaseFiles(Testing.useCleanDb)
        
        let path = Bundle.main.resourceURL!.appendingPathComponent("UITests").appendingPathComponent("Database").path
        return Database(databaseName: "balance.db", pathPrefix: path)
    }
    
    static func copyDatabaseFiles(_ clean: Bool = false) {
        let files = FileManager.default
        let base = Bundle.main.resourceURL!.appendingPathComponent("UITests").appendingPathComponent("Database")
        let srcBase = base.appendingPathComponent("db").appendingPathComponent(clean ? "clean" : "dirty")
        
        let destDb = base.appendingPathComponent("balance.db")
        let destShm = base.appendingPathComponent("balance.db-shm")
        let destWal = base.appendingPathComponent("balance.db-wal")
        
        do {
            try files.removeItem(at: destDb)
            try files.removeItem(at: destShm)
            try files.removeItem(at: destWal)
        } catch {
            print("[copyDatabaseFiles] Failed to remove db file with error: \(error)")
        }
        
        try! files.copyItem(at: srcBase.appendingPathComponent("balance.db"), to: destDb)
        try! files.copyItem(at: srcBase.appendingPathComponent("balance.db-shm"), to: destShm)
        try! files.copyItem(at: srcBase.appendingPathComponent("balance.db-wal"), to: destWal)
        
        copyUserDefaults()
    }
    
    static func copyUserDefaults() {
        defaults.setAccountIdsExcludedFromTotal(excludedAccountIds)
        defaults.accountsViewInstitutionsOrder = accountsViewInstitutionsOrder
        defaults.accountsViewAccountsOrder = accountsViewAccountsOrder
    }
}
