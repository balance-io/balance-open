//
//  ProductId.swift
//  Bal
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum ProductId: String {
    case lightMonthly   = "lightMonthly"
    case basicMonthly   = "basicMonthly"
    case basicAnnual    = "basicAnnual"
    case mediumMonthly  = "mediumMonthly"
    case mediumAnnual   = "mediumAnnual"
    case proMonthly     = "proMonthly"
    case proAnnual      = "proAnnual"
    case none           = "none"
    
    static var priceDictionary: [ProductId: Int] = [.lightMonthly:   199,
                                                    .basicMonthly:   499,
                                                    .basicAnnual:   4999,
                                                    .mediumMonthly:  999,
                                                    .mediumAnnual:  9999,
                                                    .proMonthly:    1999,
                                                    .proAnnual:    19999]
    
    static var maxAccountsDictionary: [ProductId: Int] = [.lightMonthly:   2,
                                                          .basicMonthly:   5,
                                                          .basicAnnual:    5,
                                                          .mediumMonthly: 10,
                                                          .mediumAnnual:  10,
                                                          .proMonthly:    20,
                                                          .proAnnual:     20]
    
    var tier: Int {
        switch self {
        case .lightMonthly:
            return 1
        case .basicMonthly, .basicAnnual:
            return 2
        case .mediumMonthly, .mediumAnnual:
            return 3
        case .proMonthly, .proAnnual:
            return 4
        default:
            return 0
        }
    }
    
    var price: Int {
        return ProductId.priceDictionary[self] ?? 0
    }
    
    var maxAccounts: Int {
        return ProductId.maxAccountsDictionary[self] ?? 0
    }
}
