//
//  EthploreAccountTests.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 18/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class EthploreAccountTests: XCTestCase {
    
    var json: [String:AnyObject]!
    
    override func setUp() {
        super.setUp()
        let data = TestHelpers.loadData(filename: "EthploreAccountResponse.json")
        self.json = TestHelpers.dataToJSON(data: data) as [String:AnyObject]    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEthploreAccountObjectCreationAddress() {
        //when
        let account = try! EthplorerAccountObject.init(dictionary: self.json, currencyShortName: "ETH", type: .wallet)
        
        //then
        XCTAssertEqual(account.address, "0x3c44151439965c709f7d79ceebaeda5bc5fba9ca")
    }
    
    func testEthPloreAccountObjectEth() {
        //when
        let account = try! EthplorerAccountObject.init(dictionary: self.json, currencyShortName: "ETH", type: .wallet)
        
        //then
        XCTAssertEqual(account.ETH.balance, 2.629951259)
        XCTAssertEqual(account.ETH.totalIn, 9.486951259)
        XCTAssertEqual(account.ETH.totalOut, 6.856999999999999)
    }
    
    func testEthploreAccountObjectTokenBalance() {
        //when
        let account = try! EthplorerAccountObject.init(dictionary: self.json, currencyShortName: "ETH", type: .wallet)
        XCTAssertEqual(account.tokens.count, 1)
        let token = account.tokens.first
        
        //then
        XCTAssertEqual(token?.balance, atof("3.94402043750082e+22"))
    }
    
    func testEthploreAccountObjectTokenInfo() {
        //when
        let account = try! EthplorerAccountObject.init(dictionary: self.json, currencyShortName: "ETH", type: .wallet)
        let token = account.tokens.first
        let tokenInfo = token?.tokenInfo
        
        //then
        XCTAssertEqual(tokenInfo?.address, "0xe41d2489571d322189246dafa5ebde1f4699f498")
        XCTAssertEqual(tokenInfo?.decimals, 18)
        XCTAssertEqual(tokenInfo?.name, "0x Protocol Token")
        XCTAssertNotNil(tokenInfo?.price)
        XCTAssertEqual(tokenInfo?.symbol, "ZRX")
    }
    
    func testEthploreAccountObjectTokenPrice() {
        //when
        let account = try! EthplorerAccountObject.init(dictionary: self.json, currencyShortName: "ETH", type: .wallet)
        let token = account.tokens.first
        XCTAssertNotNil(token?.tokenInfo.price)
        let tokenPrice = token?.tokenInfo.price
        
        //then
        XCTAssertEqual(tokenPrice?.rate, 0.32)
        XCTAssertEqual(tokenPrice?.currency, Currency.common(traditional: .usd))
        XCTAssertEqual(tokenPrice?.diff, 28.82)
    }
    
    func testPoloniexAccountFails() {
        //given
        let dictionary = [String:Any]()
        
        //then
        XCTAssertThrowsError(try PoloniexAccount(dictionary: dictionary as [String : AnyObject], currencyShortName: "BTC", type: AccountType.exchange))
    }

}
