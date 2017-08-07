//
//  HTTPURLResponseTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalanceOpen


internal final class HTTPURLResponseTests: XCTestCase
{
    // Private
    private let url = URL(string: "http://balancemy.money")!
    
    // MARK: Success tests
    
    internal func testSuccess()
    {
        let successResponse = HTTPURLResponse(url: self.url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        XCTAssert(successResponse.isSuccess)
        
        let errorResponse = HTTPURLResponse(url: self.url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        XCTAssert(!errorResponse.isSuccess)
    }
}
