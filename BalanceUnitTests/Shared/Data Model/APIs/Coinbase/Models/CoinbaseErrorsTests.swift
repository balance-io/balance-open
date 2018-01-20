//
//  CoinbaseErrorsTests.swift
//  BalanceUnitTests
//
//  Created by Joe Blau on 1/19/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class CoinbaseErrorsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testDecodingError_withoutURL() {
        let errorMock =
        """
        {
          "errors": [
            {
              "id": "validation_error",
              "message": "Please enter a valid email or bitcoin address"
            }
          ]
        }
        """
        guard let errorMockbData = errorMock.data(using: .utf8) else {
            XCTFail("Error unwrapping data")
            return
        }
        do {
            let coinbaseError = try decoder.decode(CoinbaseErrors.self, from: errorMockbData)
            XCTAssertEqual(coinbaseError.errors?.first?.id, "validation_error")
            XCTAssertEqual(coinbaseError.errors?.first?.message, "Please enter a valid email or bitcoin address")
            XCTAssertEqual(coinbaseError.errors?.first?.errorDescription, "Please enter a valid email or bitcoin address")
            XCTAssertNil(coinbaseError.errors?.first?.url)
        } catch {
            XCTFail("Error decoding warning")
        }
    }
    
    func testDecodingError_withURL() {
        let errorMock =
        """
        {
          "errors": [
            {
              "id": "invalid_scope",
              "message": "Invalid scope",
              "url": "http://developers.coinbase.com/api#permissions"
            }
          ]
        }
        """
        guard let errorMockData = errorMock.data(using: .utf8) else {
            XCTFail("Error unwrapping data")
            return
        }
        do {
            let coinbaseError = try decoder.decode(CoinbaseErrors.self, from: errorMockData)
            XCTAssertEqual(coinbaseError.errors?.first?.id, "invalid_scope")
            XCTAssertEqual(coinbaseError.errors?.first?.message, "Invalid scope")
            XCTAssertEqual(coinbaseError.errors?.first?.errorDescription, "Invalid scope")
            XCTAssertEqual(coinbaseError.errors?.first?.url, URL(string: "http://developers.coinbase.com/api#permissions"))
        } catch {
            XCTFail("Error decoding warning")
        }
    }
    
    func testDecodingOAuthError() {
        let errorMock =
        """
        {
            "error": "invalid_request",
            "error_description": "The request is missing a required parameter, includes an unsupported parameter value, or is otherwise malformed."
        }
        """
        guard let errorMockData = errorMock.data(using: .utf8) else {
            XCTFail("Error unwrapping data")
            return
        }
        do {
            let coinbaseOAuthError = try decoder.decode(CoinbaseOAuthError.self, from: errorMockData)
            XCTAssertEqual(coinbaseOAuthError.error, "invalid_request")
            XCTAssertEqual(coinbaseOAuthError.errorDescription, "The request is missing a required parameter, includes an unsupported parameter value, or is otherwise malformed.")
        } catch {
            XCTFail("Error decoding warning")
        }
    }
}
