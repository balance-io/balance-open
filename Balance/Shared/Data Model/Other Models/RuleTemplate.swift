//
//  RuleTemplate.swift
//  Bal
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class RuleTemplate: NSObject {
    let templateId: Int
    let name: String
    let elements: [Element]
    
    init(templateId: Int, name: String, elements: [Element]) {
        self.templateId = templateId
        self.name = name
        self.elements = elements
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? RuleTemplate {
            return object == self
        }
        return false
    }
    
    static func ==(lhs: RuleTemplate, rhs: RuleTemplate) -> Bool {
        return lhs.templateId == rhs.templateId
    }
}
