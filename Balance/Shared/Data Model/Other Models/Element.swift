//
//  Element.swift
//  Bal
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

@objc enum ElementType: Int {
    case label
    case textField
    case numberField
    case comboBox
    case button
}

class Element: NSObject {
    let type: ElementType
    let defaultValue: [String]
    let label: String?
    var stringValue: String?
    var width: CGFloat?
    
    init(type: ElementType, defaultValue: [String], stringValue: String? = nil, width: CGFloat? = nil, label: String? = nil) {
        self.type = type
        self.defaultValue = defaultValue
        self.stringValue = stringValue
        self.width = width
        self.label = label
    }
    
    override var description: String {
        return "type: \(type.rawValue) stringValue: \(String(describing: stringValue)) defaultValue: \(defaultValue) accessibilityLabel: \(String(describing: label))"
    }
}
