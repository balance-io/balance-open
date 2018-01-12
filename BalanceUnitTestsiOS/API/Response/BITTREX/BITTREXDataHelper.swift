//
//  BITTREXDataHelper.swift
//  BalanceUnitTests
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BITTREXDataHelper {

    static var targetBundle: Bundle {
        return Bundle(for: BITTREXDataHelper.self)
    }
    
    static func loadBalances() -> Data {
        return TestHelpers.loadData(filename: "balances.json", bundle: targetBundle)
    }
    
    static func loadCurrencies() -> Data {
        return TestHelpers.loadData(filename: "currencies.json", bundle: targetBundle)
    }
    
    static func loadInvalidApiKey() -> Data {
        return TestHelpers.loadData(filename: "invalid_api_key.json", bundle: targetBundle)
    }
    
}
