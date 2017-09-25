//
//  BitfinexAPIClientTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class BitfinexAPIClientTests: XCTestCase
{
    // Private
    private let mockSession = MockSession()
    private var apiClient: BitfinexAPIClient!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        let credentials = try! BitfinexAPIClient.Credentials(key: "aaa", secret: "bbb")
        
        self.apiClient = BitfinexAPIClient(session: self.mockSession)
        self.apiClient.credentials = credentials
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Fetch wallets
    
    internal func testFetchAccounts()
    {
        let data = TestHelpers.loadData(filename: "FetchWallets.json")
        self.mockSession.mockResponse = MockSession.Response(data: data, statusCode: 200, headers: nil)
        
        let expectation = self.expectation(description: "Request")
        
        try! self.apiClient.fetchWallets { (wallets, error) in
            XCTAssertNil(error)
            XCTAssertEqual(wallets?.count, 2)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
}
