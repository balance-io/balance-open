//
//  URLRequest.swift
//  BalanceOpen
//
//  Created by Red Davis on 01/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal extension URLRequest {
    internal mutating func add(headers: [String : String]) {
        for (key, value) in headers {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
}
