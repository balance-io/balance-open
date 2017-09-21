//
//  CoinbaseTransactionTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 21/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class CoinbaseTransactionTests: XCTestCase
{
    // Private
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Initialization
    
    internal func testInitialization()
    {
        let data = TestHelpers.loadData(filename: "CoinbaseSendTransaction.json")
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
        
        print(json)
        
        let transaction = try! CoinbaseApi.Transaction(dictionary: json)
        XCTAssertEqual(transaction.identifier, "57ffb4ae-0c59-5430-bcd3-3f98f797a66c")
        XCTAssertEqual(transaction.type, "send")
        XCTAssertEqual(transaction.status, "completed")
        XCTAssertEqual(transaction.amount, -0.001)
        XCTAssertEqual(transaction.currencyCode, "BTC")
        XCTAssertEqual(transaction.nativeAmount, -0.01)
        XCTAssertEqual(transaction.nativeCurrencyCode, "USD")
    }
}

