//
//  DoubleTests.swift
//  BalanceUnitTests
//
//  Created by Raimon Lapuente Ferran on 19/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class DoubleTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDoubleToIntegerTransformationWithCryptoDecimalsFixedDecimals() {
        // given
        let double = Double(5.09234913)
        
        // when
        let integerTransform = double.integerFixedCryptoDecimals()
        
        // then
        XCTAssertEqual(509234913, integerTransform)
    }
    
    func testDoubleToIntegerTransformationWithCryptoDecimalsMoreDecimals() {
        // given
        let double = 5.09234913234234
        
        // when
        let integerTransform = double.integerFixedCryptoDecimals()
        
        // then
        XCTAssertEqual(509234913, integerTransform)
    }
    
    func testDoubleToIntegerTransformationWithCryptoDecimalsLessDecimals() {
        // given
        let double = 5.0923
        
        // when
        let integerTransform = double.integerFixedCryptoDecimals()
        
        // then
        XCTAssertEqual(509230000, integerTransform)
    }
    
    func testIntegerToIntegerTransformationWithCryptoDecimalsLessDecimals() {
        // given
        let double = Double(5)
        
        // when
        let integerTransform = double.integerFixedCryptoDecimals()
        
        // then
        XCTAssertEqual(500000000, integerTransform)
    }
    
    func testDoubleToIntegerTransformationWithCryptoDecimalse22() {
        // given
        let double = 3.94402043750082e+22
        
        // when
        let integerTransform = double.cientificToEightDecimals(decimals:18)
        
        // then
        XCTAssertEqual(39440.2043750082, integerTransform)
    }
    
    func testBothMethods() {
        //given
        let double = 3.94402043750082e+22
        
        // where
        let balance = double.cientificToEightDecimals(decimals: 18)
        let noDecimals = balance.integerFixedCryptoDecimals()
        
        //then
        XCTAssertEqual(3944020437500, noDecimals)
    }
    
    func testFromTwoDecimals() {
        //given
        let double = 342.23
        
        // where
        let balance = double.cientificToEightDecimals(decimals: 2)
        
        //then
        XCTAssertEqual(342.23, balance)
    }
    
    func testFromZeroDecimals() {
        //given
        let double = Double(34223)
        
        // where
        let balance = double.cientificToEightDecimals(decimals: 2)
        
        //then
        XCTAssertEqual(34223, balance)
    }
    
    func testFromTwoDecimalsToFixedCrypto() {
        //given
        let double = 342.23
        
        // where
        let balance = double.cientificToEightDecimals(decimals: 2)
        let noDecimals = balance.integerFixedCryptoDecimals()
        
        //then
        XCTAssertEqual(34223000000, noDecimals)
    }
    
    func testFromZeroDecimalsToFixedCrypto() {
        //given
        let double = Double(34223)
        
        // where
        let balance = double.cientificToEightDecimals(decimals: 2)
        let noDecimals = balance.integerFixedCryptoDecimals()
        
        //then
        XCTAssertEqual(3422300000000, noDecimals)
    }
    
    func testFrom6DecimalsToFixedCrypto() {
        //given
        let double = Double(130049000000)
        
        //where
        let balance = double.cientificToEightDecimals(decimals: 6)
        let noDecimals = balance.integerFixedCryptoDecimals()
        
        //then
        XCTAssertEqual(13004900000000, noDecimals)
    }
}
