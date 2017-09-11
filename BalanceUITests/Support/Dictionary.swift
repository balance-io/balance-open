//
//  Dictionary.swift
//  Bal
//
//  Created by Jamie Rumbelow on 02/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(_ other: Dictionary?) {
        if other != nil {
            for ( key, value ) in other! {
                self.updateValue(value, forKey:key)
            }
        }
    }
}
