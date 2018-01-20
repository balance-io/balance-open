//
//  CoinbaseWarningsTests.swift
//  BalanceUnitTests
//
//  Created by Joe Blau on 1/19/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import XCTest
@testable import BalancemacOS

class CoinbaseWarningsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testDecodingWarning() {
        let warningMock =
        """
        {
          "warnings": [
            {
              "id": "missing_version",
              "message": "Please supply API version (YYYY-MM-DD) as CB-Version header",
              "url": "https://developers.coinbase.com/api/v2#versioning"
            }
          ]
        }
        """
        guard let warningMockData = warningMock.data(using: .utf8) else {
            XCTFail("Error unwrapping data")
            return
        }
        do {
            let coinbaseWarning = try decoder.decode(CoinbaseWarnings.self, from: warningMockData)
            XCTAssertEqual(coinbaseWarning.warnings?.first?.id, "missing_version")
            XCTAssertEqual(coinbaseWarning.warnings?.first?.message, "Please supply API version (YYYY-MM-DD) as CB-Version header")
            XCTAssertEqual(coinbaseWarning.warnings?.first?.errorDescription, "Please supply API version (YYYY-MM-DD) as CB-Version header")
            XCTAssertEqual(coinbaseWarning.warnings?.first?.url, URL(string: "https://developers.coinbase.com/api/v2#versioning"))
        } catch {
            XCTFail("Error decoding warning")
        }
    }
}
