//
//  Array.swift
//  Bal
//
//  Created by Benjamin Baron on 12/2/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Array {
    var randomItem: Element? {
        let count = self.count
        if count > 0 {
            let index = Int(arc4random_uniform(UInt32(self.count)))
            return self[index]
        }
        return nil
    }
}
