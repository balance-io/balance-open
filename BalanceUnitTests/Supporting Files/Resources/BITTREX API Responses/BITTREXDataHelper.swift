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
    
    // NOTE: This is a real API response but I've mangled the crypto addresses for privacy, so
    // they will parse correctly but may not be valid addresses or if they are may not exist.
    static func loadBalances() -> Data {
        return TestHelpers.loadData(filename: "BittrexBalances.json", bundle: targetBundle)
    }
    
    static func loadCurrencies() -> Data {
        return TestHelpers.loadData(filename: "BittrexCurrencies.json", bundle: targetBundle)
    }
    
    // NOTE: This is a real API response but I've mangled the crypto addresses, crypto transaction ids,
    // and bittrex transaction ids for privacy, so they will parse correctly but may not be valid addresses
    // or if they are may not exist.
    static func loadDeposits() -> Data {
        return TestHelpers.loadData(filename: "BittrexDeposits.json", bundle: targetBundle)
    }
    
    // NOTE: This is using the test data from Bittrex's documentation, as the API key I have to test with
    // does not have any withdrawals (but it's the same format and parsing as deposits)
    static func loadWithdrawals() -> Data {
        return TestHelpers.loadData(filename: "BittrexWithdrawals.json", bundle: targetBundle)
    }
    
    static func loadInvalidApiKey() -> Data {
        return TestHelpers.loadData(filename: "BittrexInvalidApiKey.json", bundle: targetBundle)
    }
    
}
