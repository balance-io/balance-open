//
//  BtcAccountTests.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 30/01/2018.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class BtcAccountTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBtcCreationSucess() {
        //given
        let data = TestHelpers.loadData(filename: "BtcApiResponse.json")
        let accountInfo = TestHelpers.dataToJSON(data: data)
        
        //when
        let account = try! BtcAccount(dictionary: accountInfo as [String : AnyObject], type: AccountType.wallet)
        
        //then
        XCTAssertEqual(account.finalBalance, 3051811)
    }

}
