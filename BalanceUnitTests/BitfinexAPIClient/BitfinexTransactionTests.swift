//
//  BitfinexTransactionTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 27/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class BitfinexTransactionTests: XCTestCase
{
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
        let data = TestHelpers.loadData(filename: "BitfinexMovement.json")
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [Any]
        
        let transaction = try! BitfinexAPIClient.Transaction(data: json)
        XCTAssertEqual(transaction.currencyCode, "BTC")
        XCTAssertEqual(transaction.address, "1NHtGHaHVNUJejhqTmGKPr9zbwah8Ppnj9")
        XCTAssertEqual(transaction.status, "COMPLETED")
        XCTAssertEqual(transaction.amount, 0.015113)
    }
}
