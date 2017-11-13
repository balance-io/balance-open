//
//  QRLoginCredentialsParserTests.swift
//  BalanceUnitTests
//
//  Created by Red Davis on 13/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS


internal final class QRLoginCredentialsParserTests: XCTestCase {
    // Private
    private let parser = QRLoginCredentialsParser()

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Unsupported source
    
    internal func testUnsupportedSource() {
        do {
            _ = try self.parser.parse(value: "", for: .coinbase)
            XCTFail()
        } catch let error as QRLoginCredentialsParser.ParseError {
            XCTAssertEqual(error, .unsupportedSource)
        } catch {
            XCTFail("Invalid error")
        }
    }
    
    // MARK: Kraken

    internal func testKraken() {
        let key = "123"
        let secret = "456"
        let urlString = "kraken://apikey?key=\(key)&secret=\(secret)"
        let fields = try! self.parser.parse(value: urlString, for: .kraken)
        
        let keyField = fields.first { (field) -> Bool in
            return field.type == "key"
        }
        
        XCTAssertNotNil(keyField)
        XCTAssertEqual(keyField?.value, key)
        
        let secretField = fields.first { (field) -> Bool in
            return field.type == "secret"
        }
        
        XCTAssertNotNil(secretField)
        XCTAssertEqual(secretField?.value, secret)
    }
    
    // MARK: Bitfinex
    
    internal func testBitfinex() {
        let key = "123"
        let secret = "456"
        let urlString = "user:111-key:\(key)-secret:\(secret)"
        let fields = try! self.parser.parse(value: urlString, for: .bitfinex)
        
        let keyField = fields.first { (field) -> Bool in
            return field.type == "key"
        }
        
        XCTAssertNotNil(keyField)
        XCTAssertEqual(keyField?.value, key)
        
        let secretField = fields.first { (field) -> Bool in
            return field.type == "secret"
        }
        
        XCTAssertNotNil(secretField)
        XCTAssertEqual(secretField?.value, secret)
    }
    
}

