//
//  TransferQuoteTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 22/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalanceOpen


internal final class TransferQuoteTests: XCTestCase
{
    // Private
    private let coinA: ShapeShiftAPIClient.Coin = {
        let url = URL(string: "http://balancemy.money")!
        return ShapeShiftAPIClient.Coin(name: "Bitcoin", symbol: "BTC", imageURL: url, isAvailable: true)
    }()
    
    private let coinB: ShapeShiftAPIClient.Coin = {
        let url = URL(string: "http://balancemy.money")!
        return ShapeShiftAPIClient.Coin(name: "Ether", symbol: "ETH", imageURL: url, isAvailable: true)
    }()
    
    private var coinPair: ShapeShiftAPIClient.CoinPair!
    private var marketInformation: ShapeShiftAPIClient.MarketInformation!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        // Coin pair
        self.coinPair = ShapeShiftAPIClient.CoinPair(input: coinA, output: coinB)
        
        // Market info
        let marketInforDictionary = [
            "rate" : 1.0,
            "maxLimit" : 10.0,
            "minimum" : 0.001,
            "minerFee" : 0.01
        ]
        self.marketInformation = try! ShapeShiftAPIClient.MarketInformation(coinPair: self.coinPair, dictionary: marketInforDictionary)
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Initialization
    
    internal func testInitializationWithShapeShiftMarketInfo()
    {
        let amountToSend = 0.5
        let transferQuote = try! TransferQuote(sourceAmount: amountToSend, marketInformation: self.marketInformation)
        
        XCTAssertEqual(transferQuote.sourceAmount, 0.5)
        XCTAssertEqual(transferQuote.sourceCurrency.rawValue.lowercased(), self.coinA.symbol.lowercased())
        
        XCTAssertEqual(transferQuote.recipientAmount, 0.5)
        XCTAssertEqual(transferQuote.minerFeeCurrency.rawValue.lowercased(), self.coinB.symbol.lowercased())
        XCTAssertEqual(transferQuote.recipientCurrency.rawValue.lowercased(), self.coinB.symbol.lowercased())
    }
}
