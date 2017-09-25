//
//  BitfinexCredentialsTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 13/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class BitfinexCredentialsTest: XCTestCase
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
    
    internal func testInitialization()
    {
        do
        {
            let _ = try BitfinexAPIClient.Credentials(key: "1", secret: "2")
            XCTAssert(true)
        }
        catch let error
        {
            XCTFail("Error thrown \(error)")
        }
    }
    
    // MARK: Signature
    
    internal func testSignatureGeneration()
    {
        let credentials = try! BitfinexAPIClient.Credentials(key: "1", secret: "cool-secret-bro")
        let timestamp = Date(timeIntervalSince1970: 1)
        let body = ["bo" : "dy"]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        let requestPath = "wallets"
        
        let signature = try! credentials.generateSignature(date: timestamp, requestPath: requestPath, body: bodyData)
        XCTAssertEqual(signature, "fc62eace5731c7f77fe080c842fa76511d1f0cb1e42caf0441f50e6a081dce33721a803ec0d28e0bad00a4b31fdbb85e")
    }
    
    // MARK: Saving
    
    internal func testSavingCredentials()
    {
        let key = "1"
        let secret = "secret"
        let identifier = UUID().uuidString
        
        let credentials = try! BitfinexAPIClient.Credentials(key: key, secret: secret)
        try! credentials.save(identifier: identifier)
        
        let loadedCredentials = try! BitfinexAPIClient.Credentials(identifier: identifier)
        XCTAssertEqual(loadedCredentials.components.key, key)
        XCTAssertEqual(loadedCredentials.components.secret, secret)
    }
}
