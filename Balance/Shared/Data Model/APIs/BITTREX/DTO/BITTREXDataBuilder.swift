//
//  BITTREXDataBuilder.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BITTREXDataBuilder {
 
    func createBalances(from jsonData: Data) -> [BITTREXBalance] {
        guard let balances = try? JSONDecoder().decode([BITTREXBalance].self, from: jsonData) else {
            return []
        }
        
        return balances
    }
    
    func createCurrencies(from jsonData: Data) -> [BITTREXCurrency] {
        guard let currencies = try? JSONDecoder().decode([BITTREXCurrency].self, from: jsonData) else {
            return []
        }
        
        return currencies
    }
    
}
