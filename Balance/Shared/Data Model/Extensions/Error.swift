//
//  Error.swift
//  Bal
//
//  Created by Benjamin Baron on 1/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Error {
    var domain: String {
        return (self as NSError).domain
    }
    
    var code: Int {
        return (self as NSError).code
    }
    
    var localizedDescription: String {
        return (self as NSError).localizedDescription
    }
}

// Allow for simple string exceptions
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
