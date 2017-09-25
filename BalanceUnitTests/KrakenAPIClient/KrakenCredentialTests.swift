//
//  KrakenCredentialTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 19/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class KrakenCredentialTests: XCTestCase
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
            let _ = try KrakenAPIClient.Credentials(key: "1", secret: "2")
            XCTFail()
        }
        catch let error as APICredentialsComponents.Error
        {
            switch error
            {
            case .invalidSecret:
                XCTAssert(true)
            default:
                XCTFail("invalid error")
            }
        }
        catch
        {
            XCTFail("invalid error")
        }
    }
    
    // MARK: Signature
    
    internal func testSignatureGeneration()
    {
        let requestPath = "test"
        let nonce = String(1000)
        let body = [
            "nonce" : nonce
        ].httpFormEncode()
        
        let credentials = try! KrakenAPIClient.Credentials(key: "1", secret: "aGVsbG8hIGh0dHA6Ly9yZWQudG8=")
        let signature = try! credentials.generateSignature(nonce: nonce, requestPath: requestPath, body: body)
        
        XCTAssertEqual(signature, "G9mgqnCaxLFBQMlCgL+Bg+PYwugDvFnnqNJsrlq8xUHYNnlBeiTv0/EztxYSF/7lvLn0bnhLUGplGfR04sne3g==")
    }
    
    // MARK: Saving
    
    internal func testSavingCredentials()
    {
        let key = "1"
        let secret = "aGVsbG8hIGh0dHA6Ly9yZWQudG8="
        let identifier = UUID().uuidString
        
        let credentials = try! KrakenAPIClient.Credentials(key: key, secret: secret)
        try! credentials.save(identifier: identifier)
        
        let loadedCredentials = try! KrakenAPIClient.Credentials(identifier: identifier)
        XCTAssertEqual(loadedCredentials.components.key, key)
        XCTAssertEqual(loadedCredentials.components.secret, secret)
    }
}

