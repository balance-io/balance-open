//
//  CurrentExchangeRatesTests.swift
//  BalanceUnitTests
//
//  Created by Benjamin Baron on 10/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class CurrentExchangeRateTests: XCTestCase {
    func testParse() {
        //given
        let currentExchangeRates = CurrentExchangeRates()
        let data = TestHelpers.loadData(filename: "ExchangeRates.json")
        
        //when
        let success = currentExchangeRates.parse(data: data)
        let coinbaseGdaxCount = currentExchangeRates.exchangeRates(forSource: .coinbaseGdax)?.count ?? 0
        let poloniexCount = currentExchangeRates.exchangeRates(forSource: .poloniex)?.count ?? 0
        let bitfinexCount = currentExchangeRates.exchangeRates(forSource: .bitfinex)?.count ?? 0
        let krakenCount = currentExchangeRates.exchangeRates(forSource: .kraken)?.count ?? 0
        let fixerCount = currentExchangeRates.exchangeRates(forSource: .fixer)?.count ?? 0
        
        //then
        XCTAssertTrue(success)
        XCTAssertEqual(coinbaseGdaxCount, 3)
        XCTAssertEqual(poloniexCount, 101)
        XCTAssertEqual(bitfinexCount, 15)
        XCTAssertEqual(krakenCount, 17)
        XCTAssertEqual(fixerCount, 31)
    }
    
    // Just test that we get any result from the conversion so that the exact rate doesn't matter
    func testConvertPoloniex() {
        //given
        let currentExchangeRates = CurrentExchangeRates()
        let data = TestHelpers.loadData(filename: "ExchangeRates.json")
        currentExchangeRates.parse(data: data)
        
        //when
        let ethUsd = currentExchangeRates.convert(amount: 1.0, from: .eth, to: .usd, source: .poloniex)
        let btcUsd = currentExchangeRates.convert(amount: 1.0, from: .btc, to: .usd, source: .poloniex)
        let ltcUsd = currentExchangeRates.convert(amount: 1.0, from: .ltc, to: .usd, source: .poloniex)
        
        //then
        XCTAssertNotNil(ethUsd)
        XCTAssertNotNil(btcUsd)
        XCTAssertNotNil(ltcUsd)
    }
}
