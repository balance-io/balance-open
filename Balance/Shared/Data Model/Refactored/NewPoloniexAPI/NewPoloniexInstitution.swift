//
//  NewPoloniexInstitution.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NewPoloniexInstitution: ExchangeInstitution {
    
    var source: Source = .poloniex
    var name: String = "Poloniex"
    var fields: [Field] = []
    
    init() {
        let keyField = Field(name: "API Key", type: .key, value: nil)
        let secretField = Field(name: "Secret", type: .secret, value: nil)
        self.fields = [keyField, secretField]
    }
}
