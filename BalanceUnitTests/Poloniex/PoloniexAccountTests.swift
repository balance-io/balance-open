//
//  PoloniexAccountTests.swift
//  BalanceOpenTests
//
//  Created by Raimon Lapuente on 07/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
import Foundation
@testable import BalancemacOS

class PoloniexAccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    //we want to test account creation and account creation failure that's why there are only two tests.
    //account creation also tests the logic numbers, ther isn't much so we only have two tests
    func testPoloniexAccountCreationSucess() {
        //given
        let data = TestHelpers.loadData(filename: "PoloniexAccount.json")
        let accountInfo = TestHelpers.dataToJSON(data: data)
        let (currency, dictionary) = accountInfo.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        let btcValueDecimal = NumberUtils.decimalFormatter.number(from: "0.07786885")?.decimalValue
        XCTAssertEqual(account.btcValue, btcValueDecimal)
        
        let onOrders = NumberUtils.decimalFormatter.number(from: "0.00000000")?.decimalValue
        XCTAssertEqual(account.onOrders, onOrders)
        
        let available = NumberUtils.decimalFormatter.number(from: "26576.40000000")?.decimalValue
        XCTAssertEqual(account.available, available)
    }
    
    func testPoloniexAccountFails() {
        //given
        let dictionary = [String:Any]()
        
        //then
        XCTAssertThrowsError(try PoloniexAccount(dictionary: dictionary as [String : AnyObject], currencyShortName: "BTC", type: AccountType.exchange))
    }

}
