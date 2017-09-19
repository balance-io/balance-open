//
//  KrakenAPIClientTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class KrakenAPIClientTests: XCTestCase
{
    // Private
    private let mockSession = MockSession()
    private var apiClient: KrakenAPIClient!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        let credentials = try! KrakenAPIClient.Credentials(key: "test", secret: "aGVsbG8hIGh0dHA6Ly9yZWQudG8=")
        
        self.apiClient = KrakenAPIClient(session: self.mockSession)
        self.apiClient.credentials = credentials
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Fetch wallets
    
    internal func testFetchAccounts()
    {
        let data = TestHelpers.loadData(filename: "KrakenFetchAccounts.json")
        self.mockSession.mockResponse = MockSession.Response(data: data, statusCode: 200, headers: nil)
        
        let expectation = self.expectation(description: "Request")
        
        try! self.apiClient.fetchAccounts { (accounts, error) in
            XCTAssertNil(error)
            XCTAssertEqual(accounts?.count, 2)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }
}
