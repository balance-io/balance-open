//
//  FMDatabasePoolAdditionsVariadic.swift
//  iSub
//
//  Created by Benjamin Baron on 1/14/17.
//  Copyright © 2017 Ben Baron. All rights reserved.
//

import Foundation

extension FMDatabasePool {
    func stringForQuery(_ sql: String, _ values: Any...) -> String? {
        var value: String?
        self.inDatabase { db in
            value = db.stringForQuery(sql, values)
        }
        return value
    }
    
    func intOptionalForQuery(_ sql: String, _ values: Any...) -> Int? {
        var value: Int?
        self.inDatabase { db in
            value = db.intOptionalForQuery(sql, values)
        }
        return value
    }
    
    func intForQuery(_ sql: String, _ values: Any...) -> Int {
        return intOptionalForQuery(sql, values) ?? 0
    }
    
    func int32OptionalForQuery(_ sql: String, _ values: Any...) -> Int32? {
        var value: Int32?
        self.inDatabase { db in
            value = db.int32OptionalForQuery(sql, values)
        }
        return value
    }
    
    func int32ForQuery(_ sql: String, _ values: Any...) -> Int32 {
        return int32OptionalForQuery(sql, values) ?? 0
    }
    
    func int64OptionalForQuery(_ sql: String, _ values: Any...) -> Int64? {
        var value: Int64?
        self.inDatabase { db in
            value = db.int64OptionalForQuery(sql, values)
        }
        return value
    }
    
    func int64ForQuery(_ sql: String, _ values: Any...) -> Int64 {
        return int64OptionalForQuery(sql, values) ?? 0
    }
    
    func boolOptionalForQuery(_ sql: String, _ values: Any...) -> Bool? {
        var value: Bool?
        self.inDatabase { db in
            value = db.boolOptionalForQuery(sql, values)
        }
        return value
    }
    
    func boolForQuery(_ sql: String, _ values: Any...) -> Bool {
        return boolOptionalForQuery(sql, values) ?? false
    }
    
    func doubleOptionalForQuery(_ sql: String, _ values: Any...) -> Double? {
        var value: Double?
        self.inDatabase { db in
            value = db.doubleOptionalForQuery(sql, values)
        }
        return value
    }
    
    func doubleForQuery(_ sql: String, _ values: Any...) -> Double {
        return doubleOptionalForQuery(sql, values) ?? 0.0
    }
    
    func dateForQuery(_ sql: String, _ values: Any...) -> Date? {
        var value: Date?
        self.inDatabase { db in
            value = db.dateForQuery(sql, values)
        }
        return value
    }
    
    func dataForQuery(_ sql: String, _ values: Any...) -> Data? {
        var value: Data?
        self.inDatabase { db in
            value = db.dataForQuery(sql, values)
        }
        return value
    }
}
