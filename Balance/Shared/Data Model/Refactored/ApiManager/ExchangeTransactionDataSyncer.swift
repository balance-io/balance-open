//
//  ExchangeTransactionDataSyncer.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct ExchangeTransactionDataSyncer {
    
    private let maxNumberOfCalls: Int = 2
    private var numberOfCalls: Int = 0 {
        didSet {
            guard numberOfCalls == maxNumberOfCalls else {
                return
            }
            
            dataDelegate?.process(deposits: deposits, withdrawals: withdraws)
        }
    }
    
    var deposits: Any = [] {
        didSet {
            incrementCalls()
        }
    }
    
    var withdraws: Any = [] {
        didSet {
            incrementCalls()
        }
    }
    
    weak var dataDelegate: ExchangeTransactionDataDelegate?
    
    mutating func incrementCalls() {
        guard numberOfCalls < maxNumberOfCalls else {
            return
        }
        
        numberOfCalls += 1
    }
    
}
