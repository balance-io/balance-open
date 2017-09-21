//
//  FeedTest.swift
//  Bal
//
//  Created by Jamie Rumbelow on 15/09/2016.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import BalancemacOS

class FeedRuleTest: XCTestCase {
    
    func disable_testDisplayName() {
        let strValue = "test " + String.random()
        let numValue = "100"
        let orderedTokensWithExpectedStrings: [SearchToken:String] =
        [
            .amount: "amount $100.00",
            .`in`: "in \(strValue)",
            .account: "account \(strValue)",
            .name: "name \"\(strValue)\"",
            .nameMatches: "name= \"\(strValue)\"",
            .nameMatchesNot: "-name= \"\(strValue)\"",
            .categoryMatches: "category= \"\(strValue)\""
        ]
        
        for (token, expectedString) in orderedTokensWithExpectedStrings {
            let val = [ .amount ].contains(token) ? numValue : strValue
            let rule = Rule(ruleId: "0", name: "", notify: false, searchTokens: [ token: val ])
            
            XCTAssertEqual(rule.displayName, expectedString)
        }
    }
    
    func disable_testDisplayname_NewRuleWhenNoName() {
        let newRule = Rule(ruleId: "0", name: "", notify: false, searchTokens: [:])
        XCTAssertEqual(newRule.displayName, "New Rule")
        }
    
    func disable_testDisplayname_MultipleRule() {
        let multipleRule = Rule(ruleId: "0", name: "", notify: false, searchTokens: [ .`in`: "account name", .amount: "$500" ])
        XCTAssertEqual(multipleRule.displayName, "More than $500.00, in account name")
    }
    
}

//
// Thanks http://stackoverflow.com/a/34763610/39979
//

extension String {
    
    static func random(_ length: Int = 20) -> String {
        
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.length))
            randomString += "\(base[base.characters.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return randomString
    }
}
