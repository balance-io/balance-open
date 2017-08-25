//
//  PoloniexAccountToAccountTests.swift
//  BalanceOpenTests
//
//  Created by Raimon Lapuente on 09/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class PoloniexAccountToAccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDecimalCurrencyForBTC() {
        //given
        let dict: [String:Any] = ["BTC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"0.17786885"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.currency.decimals, 8)
    }
    
    func testAltDecimalCurrencyAlwaysBTC() {
        //given
        let dict: [String:Any] = ["BTC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"0.17786885"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.currency.decimals, 8)
    }
    
    func testCurrencyBalanceForSC() {
        //given
        let dict: [String:Any] = ["SC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"26576.400000005"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.balance, Int(2657640000000))
    }
    
    func testCurrencyBalanceForBTC() {
        //given
        let dict: [String:Any] = ["BTC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"0.17786885"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.balance, Int(17786885))
    }
    
    func testCurrencyAltBalanceForSC() {
        //given
        let dict: [String:Any] = ["SC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"26576.400000005"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.altBalance, Int(17786885))
    }
    
    func testCurrencyAltBalanceForBTC() {
        //given
        let dict: [String:Any] = ["BTC":["btcValue":"0.17786885","onOrders":"0.00000000","available":"0.17786885"]]
        let (currency, dictionary) = dict.first!
        
        //when
        let account = try! PoloniexAccount(dictionary: dictionary as! [String : AnyObject], currencyShortName: currency, type: AccountType.exchange)
        
        //then
        XCTAssertEqual(account.altBalance, Int(17786885))
    }

}
