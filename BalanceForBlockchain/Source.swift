//
//  Source.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

/// This data is duplicated in the sources database table for use in joins if needed
enum Source: Int, CustomStringConvertible {
    case plaid = 1
    
    var description: String {
        switch self {
        case .plaid: return "Plaid"
        }
    }
}
