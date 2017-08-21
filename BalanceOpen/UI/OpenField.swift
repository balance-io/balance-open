//
//  Field.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente Ferran on 16/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

public struct OpenField {
    public var name: String
    public var label: String
    public var type: String
    public var value: String?
    
    public init(name: String, label: String, type: String, value: String?) {
        self.name = name
        self.label = label
        self.type = type
        self.value = value
    }
}
