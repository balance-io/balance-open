//
//  UtilsTests.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 22/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS
class UtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testCheckTypeInteger() {
        // given
        let dictionary = ["decimals": 19]
        do {
            let integer: Int = try checkType(dictionary["decimals"], name: "decimals")
            XCTAssert(integer == 19)
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeDouble() {
        // given
        let dictionary = ["decimals": 19.0]
        do {
            let double: Double = try checkType(dictionary["decimals"], name: "decimals")
            XCTAssert(double == 19.0)
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeFloat() {
        // given
        let dictionary = ["decimals": Float(19.0)]
        do {
            let float: Float = try checkType(dictionary["decimals"], name: "decimals")
            XCTAssert(float == 19.0)
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeString() {
        // given
        let dictionary = ["decimals": "19.0"]
        do {
            let string: String = try checkType(dictionary["decimals"], name: "decimals")
            XCTAssert(string == "19.0")
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
}
