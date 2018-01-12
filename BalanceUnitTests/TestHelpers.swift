//
//  TestHelpers.swift
//  BalanceOpenTests
//
//  Created by Raimon Lapuente on 07/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest

class TestHelpers {
    
    static func loadData(filename: String, bundle: Bundle? = nil) -> Data {
        let fileURL = Bundle(for: TestHelpers.self).url(forResource: filename, withExtension: "")!
        return try! Data(contentsOf: fileURL)
    }
    
    static func dataToJSON(data: Data) -> [String: Any] {
        var dict = [String: Any]()
        do{
            guard let parsed = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                XCTAssert(false)
                return [String: Any]()
            }
            dict = parsed
        }
        catch {
            XCTAssert(false)
        }
        return dict
    }
}
