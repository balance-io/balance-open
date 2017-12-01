//
//  KeychainWrapperTests.swift
//  BalanceUnitTests
//
//  Created by Benjamin Baron on 12/1/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import BalancemacOS

class KeychainWrapperTests: XCTestCase {
    let setNewDictionaryIdentifier = "testSetNewDictionary"
    let setUpdateDictionaryIdentifier = "testSetUpdateDictionary"
    let setDeleteDictionaryIdentifier = "testSetDeleteDictionary"
    
    override func tearDown() {
        try? KeychainWrapper.deleteDictionary(forIdentifier: setNewDictionaryIdentifier)
        try? KeychainWrapper.deleteDictionary(forIdentifier: setUpdateDictionaryIdentifier)
    }
    
    func testSetNewDictionary() {
        let setDict: [String: Any] = ["Key1": "Value1", "Key2": "Value2"]
        
        XCTAssertNoThrow(try KeychainWrapper.setDictionary(setDict, forIdentifier: setNewDictionaryIdentifier))
        
        var getDict: [String: Any]? = nil
        XCTAssertNoThrow(getDict = try KeychainWrapper.getDictionary(forIdentifier: setNewDictionaryIdentifier))
        XCTAssertNotNil(getDict)
        XCTAssertEqual(setDict["Key1"] as? String, getDict?["Key1"] as? String)
        XCTAssertEqual(setDict["Key2"] as? String, getDict?["Key2"] as? String)
    }
    
    func testSetUpdateDictionary() {
        let setDict: [String: Any] = ["Key1": "Value1", "Key2": "Value2"]
        let setDict2: [String: Any] = ["Key1": "Value3", "Key2": "Value4"]
        
        XCTAssertNoThrow(try KeychainWrapper.setDictionary(setDict, forIdentifier: setUpdateDictionaryIdentifier))
        
        var getDict: [String: Any]? = nil
        XCTAssertNoThrow(getDict = try KeychainWrapper.getDictionary(forIdentifier: setUpdateDictionaryIdentifier))
        XCTAssertNotNil(getDict)
        XCTAssertEqual(setDict["Key1"] as? String, getDict?["Key1"] as? String)
        XCTAssertEqual(setDict["Key2"] as? String, getDict?["Key2"] as? String)
        
        XCTAssertNoThrow(try KeychainWrapper.setDictionary(setDict2, forIdentifier: setUpdateDictionaryIdentifier))
        
        var getDict2: [String: Any]? = nil
        XCTAssertNoThrow(getDict2 = try KeychainWrapper.getDictionary(forIdentifier: setUpdateDictionaryIdentifier))
        XCTAssertNotNil(getDict2)
        XCTAssertEqual(setDict2["Key1"] as? String, getDict2?["Key1"] as? String)
        XCTAssertEqual(setDict2["Key2"] as? String, getDict2?["Key2"] as? String)
    }
    
    func testDeleteDictionary() {
        let setDict: [String: Any] = ["Key1": "Value1", "Key2": "Value2"]
        
        XCTAssertNoThrow(try KeychainWrapper.setDictionary(setDict, forIdentifier: setDeleteDictionaryIdentifier))
        
        var getDict: [String: Any]? = nil
        XCTAssertNoThrow(getDict = try KeychainWrapper.getDictionary(forIdentifier: setDeleteDictionaryIdentifier))
        XCTAssertNotNil(getDict)
        XCTAssertEqual(setDict["Key1"] as? String, getDict?["Key1"] as? String)
        XCTAssertEqual(setDict["Key2"] as? String, getDict?["Key2"] as? String)
        
        XCTAssertNoThrow(try KeychainWrapper.deleteDictionary(forIdentifier: setDeleteDictionaryIdentifier))
        XCTAssertNoThrow(getDict = try KeychainWrapper.getDictionary(forIdentifier: setDeleteDictionaryIdentifier))
        XCTAssertNil(getDict)
    }
}
