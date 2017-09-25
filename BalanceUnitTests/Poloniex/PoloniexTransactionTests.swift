//
//  PoloniexTransactionTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 25/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class PoloniexTransactionTests: XCTestCase {
    // Private
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Initialization
    
    internal func testDepositInitialization() {
        let depositData = TestHelpers.loadData(filename: "PoloniexDeposit.json")
        let depositJSON = TestHelpers.dataToJSON(data: depositData)
        let transaction = try! PoloniexApi.Transaction(depositDictionary: depositJSON)
        
        XCTAssertEqual(transaction.identifier, "17f819a91369a9ff6c4a34216d434597cfc1b4a3d0489b46bd6f924137a47701")
        XCTAssertEqual(transaction.category, .deposit)
        XCTAssertEqual(transaction.address, "123")
        XCTAssertEqual(transaction.amount, 0.01006132)
        XCTAssertEqual(transaction.currencyCode, "BTC")
        XCTAssertEqual(transaction.status, "COMPLETE")
        XCTAssertEqual(transaction.numberOfConfirmations, 10)
    }
    
    internal func testWithdrawalInitialization() {
        let withdrawalData = TestHelpers.loadData(filename: "PoloniexWithdrawal.json")
        let withdrawalJSON = TestHelpers.dataToJSON(data: withdrawalData)
        let transaction = try! PoloniexApi.Transaction(withdrawalDictionary: withdrawalJSON)
        
        XCTAssertEqual(transaction.identifier, "36e483efa6aff9fd53a235177579d98451c4eb237c210e66cd2b9a2d4a988f8e")
        XCTAssertEqual(transaction.category, .withdrawal)
        XCTAssertEqual(transaction.address, "1N2i5n8DwTGzUq2Vmn9TUL8J1vdr1XBDFg")
        XCTAssertEqual(transaction.amount, 5.0001)
        XCTAssertEqual(transaction.currencyCode, "BTC")
        XCTAssertEqual(transaction.status, "COMPLETE")
    }
}
