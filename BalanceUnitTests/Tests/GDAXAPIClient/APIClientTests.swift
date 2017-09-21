//
//  GDAXAPIClientTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class GDAXAPIClientTests: XCTestCase
{
    // Private
    private let mockSession = MockSession()
    private var apiClient: GDAXAPIClient!
    
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
        
        let credentials = try! GDAXAPIClient.Credentials(key: "1", secret: "YmFsYW5jZWlzYXdlc29tZQ==", passphrase: "3")
        
        self.apiClient = GDAXAPIClient(server: .sandbox, session: self.mockSession)
        self.apiClient.credentials = credentials
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Helpers
    
    private func loadMockData(filename: String) -> Data
    {
        let fileURL = Bundle(for: GDAXAPIClientTests.self).url(forResource: filename, withExtension: "")!
        return try! Data(contentsOf: fileURL)
    }
    
    // MARK: Fetch accounts
    
    internal func testFetchAccounts()
    {
        let data = self.loadMockData(filename: "FetchAccounts.json")
        self.mockSession.mockResponse = MockSession.Response(data: data, statusCode: 200, headers: nil)
        
        let expectation = self.expectation(description: "Request")
        
        try! self.apiClient.fetchAccounts { (accounts, error) in
            XCTAssertNil(error)
            XCTAssertEqual(accounts?.count, 2)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // MARK: Withdrawing
    
    internal func testMakingAWithdrawel()
    {
        let data = self.loadMockData(filename: "WithdrawToCrypto.json")
        self.mockSession.mockResponse = MockSession.Response(data: data, statusCode: 200, headers: nil)
        
        let expectation = self.expectation(description: "Request")
        
        // Make request
        let withdrawal = GDAXAPIClient.Withdrawal(amount: 0.001, currencyCode: "BTC", recipientCryptoAddress: "1v6x2USxJpFnCBguLmnKx3BfkGZr1drXJ")
        
        try! self.apiClient.make(withdrawal: withdrawal) { (success, error) in
            XCTAssertNil(error)
            XCTAssertTrue(success)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // MARK: Errors
    
    internal func testErrorResult()
    {
        let data = self.loadMockData(filename: "Error.json")
        self.mockSession.mockResponse = MockSession.Response(data: data, statusCode: 400, headers: nil)
        
        let expectation = self.expectation(description: "Request")
        
        // Make request
        let withdrawal = GDAXAPIClient.Withdrawal(amount: 0.001, currencyCode: "BTC", recipientCryptoAddress: "1v6x2USxJpFnCBguLmnKx3BfkGZr1drXJ")
        
        try! self.apiClient.make(withdrawal: withdrawal) { (success, error) in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            XCTAssertNotNil(error?.errorDescription)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
}
