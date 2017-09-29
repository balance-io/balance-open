//
//  CurrencyTests.swift
//  BalanceOpenTests
//
//  Created by Raimon Lapuente on 10/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class CurrencyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNumberOfDecimalsForDollar() {
        //given
        let currency = Currency.rawValue(shortName: "USD")
        
        //then
        XCTAssertEqual(currency.decimals, 2)
    }
    
    func testNumberOfDecimalsForPound() {
        //given
        let currency = Currency.rawValue(shortName: "GBP")
        
        //then
        XCTAssertEqual(currency.decimals, 2)
    }
    
    func testNumberOfDecimalsForBTC() {
        //given
        let currency = Currency.rawValue(shortName: "BTC")
        
        //then 
        XCTAssertEqual(currency.decimals, 8)
    }
    
    func testNumberOfDecimalsForEther() {
        //given
        let currency = Currency.rawValue(shortName: "ETH")
        
        //then
        XCTAssertEqual(currency.decimals, 8)
    }
    
    func testNumberOfDecimalsForOtherCryptoSC() {
        //given
        let currency = Currency.rawValue(shortName: "SC")
        
        //then
        XCTAssertEqual(currency.decimals, 8)
    }
    
    func testNumberOfDecimalsForOtherCryptoXRP() {
        //given
        let currency = Currency.rawValue(shortName: "XRP")
        
        //then
        XCTAssertEqual(currency.decimals, 8)
    }

}
