//
//  HeadersTests.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class HeadersTests: XCTestCase
{
    // MARK: Setup
    
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Dictionary generation
    
    internal func testDictionaryGeneration()
    {
        let key = "1"
        let passPhrase = "3"
        
        let credentials = try! GDAXAPIClient.Credentials(key: key, secret: "YmFsYW5jZWlzYXdlc29tZQ==", passphrase: passPhrase)
        let body = ["bo" : "dy"]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        let method = "GET"
        let requestPath = "/accounts"
        
        let header = try! GDAXAPIClient.AuthHeaders(credentials: credentials, requestPath: requestPath, method: method, body: bodyData)
        let headerDictionary = header.dictionary
        
        XCTAssertEqual(headerDictionary["CB-ACCESS-KEY"]! as String, key)
        XCTAssertEqual(headerDictionary["CB-ACCESS-PASSPHRASE"]! as String, passPhrase)
        XCTAssertNotNil(headerDictionary["CB-ACCESS-SIGN"])
        XCTAssertNotNil(headerDictionary["CB-ACCESS-TIMESTAMP"])
    }
}
