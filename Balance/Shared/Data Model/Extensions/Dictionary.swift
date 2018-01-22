//
//  Dictionary.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 1/19/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Dictionary where Value: Comparable {
    var sortedByValue:[(Key,Value)] {return Array(self).sorted{$0.1 < $1.1}}
}

extension Dictionary where Key: Comparable {
    var sortedByKey:[(Key,Value)] {return Array(self).sorted{$0.0 < $1.0}}
}
