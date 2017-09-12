//
//  Credentials.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 25/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class CredentialsTest: XCTestCase
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
    
    // MARK: Initialization
    
    internal func testInitializationWithInvalidSecret()
    {
        do
        {
            let _ = try GDAXAPIClient.Credentials(key: "1", secret: "2", passphrase: "3")
            XCTFail()
        }
        catch APICredentialsComponents.InitializationError.invalidSecret
        {
            XCTAssert(true)
        }
        catch
        {
            XCTFail("Invalid error thrown")
        }
    }
    
    // MARK: Signature
    
    internal func testSignatureGeneration()
    {
        let credentials = try! GDAXAPIClient.Credentials(key: "1", secret: "YmFsYW5jZWlzYXdlc29tZQ==", passphrase: "3")
        let timestamp = Date(timeIntervalSince1970: 1)
        let body = ["bo" : "dy"]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        let method = "GET"
        let requestPath = "/accounts"
        
        let signature = try! credentials.generateSignature(timestamp: timestamp, requestPath: requestPath, body: bodyData, method: method)
        XCTAssertEqual(signature, "ODGv+LZO8+SiSnM4GpflI9T+Qzlny0fn1eiGHv7WfVY=")
    }
    
    // MARK: Saving
    
    internal func testSavingCredentials()
    {
        let key = "1"
        let secret = "YmFsYW5jZWlzYXdlc29tZQ=="
        let passphrase = "3"
        let identifier = UUID().uuidString
        
        let credentials = try! GDAXAPIClient.Credentials(key: key, secret: secret, passphrase: passphrase)
        try! credentials.save(identifier: identifier)
        
        let loadedCredentials = try! GDAXAPIClient.Credentials(identifier: identifier)
        XCTAssertEqual(loadedCredentials.components.key, key)
        XCTAssertEqual(loadedCredentials.components.secret, secret)
        XCTAssertEqual(loadedCredentials.components.passphrase, passphrase)
    }
}
