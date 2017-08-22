//
//  XCTest+MockData.swift
//  BalanceOpenTests
//
//  Created by Red Davis on 22/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

internal extension XCTestCase
{
    internal func loadMockData(filename: String) -> Data
    {
        let fileURL = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "")!
        return try! Data(contentsOf: fileURL)
    }
}
