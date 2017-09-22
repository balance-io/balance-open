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
        var integer: Int
        let dictionary = ["decimals":19]
        do {
            integer = try checkType(dictionary, name: "decimals")
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeDouble() {
        // given
        var double: Double
        let dictionary = ["decimals":19]
        do {
            double = try checkType(dictionary, name: "decimals")
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeFloat() {
        // given
        var float: Float
        let dictionary = ["decimals":19.0]
        do {
            float = try checkType(dictionary, name: "decimals")
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
    
    func testCheckTypeString() {
        // given
        var float: String
        let dictionary = ["decimals":"19.0"]
        do {
            float = try checkType(dictionary, name: "decimals")
        } catch {
            print("Other error: \(error)")
            XCTAssert(false)
        }
    }
}
