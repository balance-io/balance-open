//
//  EnumCollection.swift
//  Balance
//
//  Created by Red Davis on 17/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


public protocol EnumCollection: Hashable {
    static var allCases: [Self] { get }
}


public extension EnumCollection {
    public static var allCases: [Self] {
        let sequence = AnySequence { () -> AnyIterator<Self> in
            var rawValue = 0
            
            let iterator = AnyIterator { () -> Self? in
                let value = withUnsafePointer(to: &rawValue, { (pointer) in
                    pointer.withMemoryRebound(to: self, capacity: 1, { (pointer) -> Self in
                        return pointer.pointee
                    })
                })
                
                guard value.hashValue == rawValue else {
                    return nil
                }
                
                rawValue += 1
                return value
            }
            
            return iterator
        }
        
        return Array(sequence)
    }
}
