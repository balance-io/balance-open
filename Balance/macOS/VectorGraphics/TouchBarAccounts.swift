//
//  TouchBarAccounts.swift
//  BalanceVectorGraphics
//
//  Created by Benjamin Baron on 12/10/16.
//  Copyright © 2016 Balanced Software. All rights reserved.
//

import Foundation

// Only need to create entries for primary institutions, the rest are looked up in the db
fileprivate let lookupTable: [String: (_ frame: NSRect, _ original: Bool, _ pressed: Bool) -> ()] =
    [:]

public extension TouchBarAccountButtons {
    public static func drawingFunction(forType type: String) -> ((_ frame: NSRect, _ original: Bool, _ pressed: Bool) -> ())? {
        return lookupTable[type]
    }
}
