//
//  FMDatabaseAdditionsVariadic.swift
//  FMDB
//

import Foundation

extension FMDatabase {
    fileprivate func valueForQuery<T>(_ sql: String, _ values: [Any]?, completionHandler:(FMResultSet)->(T!)) -> T? {
        var result: T?
        
        // Handle chained variadic functions
        var arguments = values
        while let first = arguments?.first as? [Any] {
            arguments = first
        }
        
        if let rs = executeQuery(sql, withArgumentsIn: arguments) {
            if rs.next() {
                let obj: Any = rs.object(forColumnIndex: 0)
                if !(obj is NSNull) {
                    result = completionHandler(rs)
                }
            }
            rs.close()
        }
        
        return result
    }
    
    func stringForQuery(_ sql: String, _ values: Any...) -> String? {
        return valueForQuery(sql, values) { $0.string(forColumnIndex: 0) }
    }
    
    func intOptionalForQuery(_ sql: String, _ values: Any...) -> Int? {
        return valueForQuery(sql, values) { $0.long(forColumnIndex: 0) }
    }
    
    func intForQuery(_ sql: String, _ values: Any...) -> Int {
        return intOptionalForQuery(sql, values) ?? 0
    }
    
    func int32OptionalForQuery(_ sql: String, _ values: Any...) -> Int32? {
        return valueForQuery(sql, values) { $0.int(forColumnIndex: 0) }
    }
    
    func int32ForQuery(_ sql: String, _ values: Any...) -> Int32 {
        return int32OptionalForQuery(sql, values) ?? 0
    }
    
    func int64OptionalForQuery(_ sql: String, _ values: Any...) -> Int64? {
        return valueForQuery(sql, values) { $0.longLongInt(forColumnIndex: 0) }
    }
    
    func int64ForQuery(_ sql: String, _ values: Any...) -> Int64 {
        return int64OptionalForQuery(sql, values) ?? 0
    }
    
    func boolOptionalForQuery(_ sql: String, _ values: Any...) -> Bool? {
        return valueForQuery(sql, values) { $0.bool(forColumnIndex: 0) }
    }
    
    func boolForQuery(_ sql: String, _ values: Any...) -> Bool {
        return boolOptionalForQuery(sql, values) ?? false
    }
    
    func doubleOptionalForQuery(_ sql: String, _ values: Any...) -> Double? {
        return valueForQuery(sql, values) { $0.double(forColumnIndex: 0) }
    }
    
    func doubleForQuery(_ sql: String, _ values: Any...) -> Double {
        return doubleOptionalForQuery(sql, values) ?? 0.0
    }
    
    func dateForQuery(_ sql: String, _ values: Any...) -> Date? {
        return valueForQuery(sql, values) { $0.date(forColumnIndex: 0) }
    }
    
    func dataForQuery(_ sql: String, _ values: Any...) -> Data? {
        return valueForQuery(sql, values) { $0.data(forColumnIndex: 0) }
    }
}
