//
//  Rule.swift
//  Bal
//
//  Created by Benjamin Baron on 3/8/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Rule: Object {
    @objc dynamic var ruleId = ""
    @objc dynamic var name = ""
    @objc dynamic var notify = false
    @objc dynamic var created = Date()
    
    // List of search tokens representing this rule, i.e. [.Name: "Uber", .More: "50"]
    let searchTokenValues = List<SearchTokenValue>()
    
    var searchTokens: [SearchToken: String] {
        return searchTokensFromList(searchTokenValues)
    }
    
    func updateSearchTokens(_ searchTokens: [SearchToken: String], withoutNotifying tokens: [NotificationToken] = []) {
        realmManager.writePrefs(withoutNotifying: tokens) { realm in
            for value in searchTokenValues {
                realm.delete(value)
            }
            searchTokenValues.removeAll()
            searchTokenValues.append(objectsIn: searchTokenValuesFromDict(searchTokens))
        }
    }
    
    var generatedName: String {
        let orderedTokens: [SearchToken] = [.over, .under, .amount, .accountMatches, .name, .nameMatches, .nameNot, .nameMatchesNot, .categoryMatches]
        
        var displayNameParts = [String]()
        for token in orderedTokens {
            if let value = searchTokens[token] {
                switch token {
                case .over:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("over \(amount)")
                    }
                case .under:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("under \(amount)")
                    }
                case .amount:
                    if let cents = stringToCents(value) {
                        let amount = centsToString(cents)
                        displayNameParts.append("exactly \(amount)")
                    }
                case .accountMatches:
                    displayNameParts.append("in \(value)")
                case .name:
                    displayNameParts.append("containing \"\(value)\"")
                case .nameMatches:
                    displayNameParts.append("matching \"\(value)\"")
                case .nameNot:
                    displayNameParts.append("not containing \"\(value)\"")
                case .nameMatchesNot:
                    displayNameParts.append("not matching \"\(value)\"")
                case .categoryMatches:
                    displayNameParts.append("in category \"\(value)\"")
                default:
                    break
                }
            }
        }
        
        if displayNameParts.count == 0 {
            return "New Rule"
        } else {
            return (displayNameParts as NSArray).componentsJoined(by: ", ").capitalizedFirstLetterString
        }
    }
    
    var displayName: String {
        if name.length > 0 {
            return name
        }
        return generatedName
    }
    
    convenience init(ruleId: String, name: String, notify: Bool, searchTokens: [SearchToken: String]) {
        self.init()
        self.ruleId = ruleId
        self.name = name
        self.notify = notify
        self.updateSearchTokens(searchTokens)
    }
    
    override var hashValue: Int {
        return ruleId.hashValue
    }
    
    static func ==(lhs: Rule, rhs: Rule) -> Bool {
        return lhs.ruleId == rhs.ruleId
    }
}

class SearchTokenValue: Object {
    @objc dynamic var tokenName = ""
    @objc dynamic var value = ""
    
    convenience init(token: SearchToken, value: String) {
        self.init()
        self.tokenName = token.rawValue
        self.value = value
    }
    
    var token: SearchToken? {
        return SearchToken(rawValue: tokenName)
    }
}

fileprivate func searchTokenValuesFromDict(_ dict: [SearchToken: String]) -> List<SearchTokenValue> {
    let list = List<SearchTokenValue>()
    for (token, value) in dict {
        list.append(SearchTokenValue(token: token, value: value))
    }
    return list
}

fileprivate func searchTokensFromList(_ list: List<SearchTokenValue>) -> [SearchToken: String] {
    var dict = [SearchToken: String]()
    for searchTokenValue in list {
        if let token = SearchToken(rawValue: searchTokenValue.tokenName) {
            dict[token] = searchTokenValue.value
        }
    }
    return dict
}
