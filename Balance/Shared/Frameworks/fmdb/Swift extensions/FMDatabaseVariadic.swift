//
//  FMDatabaseVariadic.swift
//  FMDB
//


//  This extension inspired by http://stackoverflow.com/a/24187932/1271826

import Foundation

extension FMDatabase {
    
    /// This is a rendition of executeQuery that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// This throws any error that occurs.
    ///
    /// - parameter sql:     The SQL statement to be used.
    /// - parameter values:  The values to be bound to the ? placeholders
    ///
    /// - returns:           This returns FMResultSet if successful. If unsuccessful, it throws an error.
    
    func executeQuery(_ sql: String, _ values: Any...) throws -> FMResultSet {
        return try executeQuery(sql, values: values as [Any]);
    }
    
    /// This is a rendition of executeUpdate that handles Swift variadic parameters
    /// for the values to be bound to the ? placeholders in the SQL.
    ///
    /// This throws any error that occurs.
    ///
    /// - parameter sql:     The SQL statement to be used.
    /// - parameter values:  The values to be bound to the ? placeholders
    
    func executeUpdate(_ sql: String, _ values: Any...) throws {
        try executeUpdate(sql, values: values as [Any]);
    }
}
