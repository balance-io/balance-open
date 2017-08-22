//
//  ShapeShiftCoinPairTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalanceOpen


internal final class ShapeShiftCoinPairTests: XCTestCase
{
    private let coinA: ShapeShiftAPIClient.Coin = {
        let url = URL(string: "http://balancemy.money")!
        return ShapeShiftAPIClient.Coin(name: "Bitcoin", symbol: "BTC", imageURL: url, isAvailable: true)
    }()
    
    private let coinB: ShapeShiftAPIClient.Coin = {
        let url = URL(string: "http://balancemy.money")!
        return ShapeShiftAPIClient.Coin(name: "Ether", symbol: "ETH", imageURL: url, isAvailable: true)
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
    
    // MARK: Code
    
    internal func testFetchingCoins()
    {
        let pair = ShapeShiftAPIClient.CoinPair(input: self.coinA, output: self.coinB)
        XCTAssertEqual(pair.input, self.coinA)
        XCTAssertEqual(pair.output, self.coinB)
        XCTAssertEqual(pair.code, "btc_eth")
    }
}

