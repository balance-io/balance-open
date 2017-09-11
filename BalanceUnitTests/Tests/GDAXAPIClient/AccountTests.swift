//
//  AccountTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class AccountTests: XCTestCase
{
    // Private
    private let accountJSON: [String : Any] = {
        let fileURL = Bundle(for: AccountTests.self).url(forResource: "Account", withExtension: "json")!
        let data = try! Data(contentsOf: fileURL)
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        
        return json as! [String : Any]
    }()
    
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
        let account = try! GDAXAPIClient.Account(dictionary: self.accountJSON)
        
        XCTAssertEqual(account.identifier, "e316cb9a-0808-4fd7-8914-97829c1925de")
        XCTAssertEqual(account.profileID, "75da88c5-05bf-4f54-bc85-5c775bd68254")
        XCTAssertEqual(account.currencyCode, "USD")
        XCTAssertEqual(account.balance, 80.2301373066930000)
        XCTAssertEqual(account.heldFunds, 1.0035025000000000)
        XCTAssertEqual(account.availableBalance, 79.2266348066930000)
    }
}
