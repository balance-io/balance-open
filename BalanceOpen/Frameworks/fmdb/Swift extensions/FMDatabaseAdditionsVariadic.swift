//
//  FMDatabaseAdditionsVariadic.swift
//  FMDB
//

import Foundation

extension FMDatabase {
    
    /// Private generic function used for the variadic renditions of the FMDatabaseAdditions methods
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The NSArray of the arguments to be bound to the ? placeholders in the SQL.
    /// - parameter completionHandler:  The closure to be used to call the appropriate FMDatabase method to return the desired value.
    ///
    /// - returns:                      This returns the T value if value is found. Returns nil if column is NULL or upon error.
    
    private func valueForQuery<T>(_ sql: String, values: [Any]?, completionHandler:(FMResultSet)->(T!)) -> T? {
        var result: T?
        
        if let rs = executeQuery(sql, withArgumentsIn: values) {
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
    
    /// This is a rendition of stringForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns string value if value is found. Returns nil if column is NULL or upon error.
    
    func stringForQuery(_ sql: String, _ values: Any...) -> String? {
        return valueForQuery(sql, values: values) { $0.string(forColumnIndex: 0) }
    }
    
    /// This is a rendition of intForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:       This returns integer value if value is found. Returns nil if column is NULL or upon error.
    
    func intForQuery(_ sql: String, _ values: Any...) -> Int32 {
        return valueForQuery(sql, values: values) { $0.int(forColumnIndex: 0) } ?? 0
    }
    
    /// This is a rendition of longForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns long value if value is found. Returns nil if column is NULL or upon error.
    
    func longForQuery(_ sql: String, _ values: Any...) -> Int {
        return valueForQuery(sql, values: values) { $0.long(forColumnIndex: 0) } ?? 0
    }
    
    /// This is a rendition of boolForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns Bool value if value is found. Returns nil if column is NULL or upon error.
    
    func boolForQuery(_ sql: String, _ values: Any...) -> Bool {
        return valueForQuery(sql, values: values) { $0.bool(forColumnIndex: 0) } ?? false
    }
    
    /// This is a rendition of doubleForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns Double value if value is found. Returns nil if column is NULL or upon error.
    
    func doubleForQuery(_ sql: String, _ values: Any...) -> Double {
        return valueForQuery(sql, values: values) { $0.double(forColumnIndex: 0) } ?? 0.0
    }
    
    /// This is a rendition of dateForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns NSDate value if value is found. Returns nil if column is NULL or upon error.
    
    func dateForQuery(_ sql: String, _ values: Any...) -> Date? {
        return valueForQuery(sql, values: values) { $0.date(forColumnIndex: 0) }
    }
    
    /// This is a rendition of dataForQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// - parameter sql:                The SQL statement to be used.
    /// - parameter values:             The values to be bound to the ? placeholders
    ///
    /// - returns:                      This returns NSData value if value is found. Returns nil if column is NULL or upon error.
    
    func dataForQuery(_ sql: String, _ values: Any...) -> Data? {
        return valueForQuery(sql, values: values) { $0.data(forColumnIndex: 0) }
    }
}
