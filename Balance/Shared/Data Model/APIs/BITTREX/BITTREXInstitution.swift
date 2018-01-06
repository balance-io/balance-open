//
//  BITTREXInstitution.swift
//  Balance
//
//  Created by Mac on 12/9/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BITTREXInstitution: ApiInstitution {
    let source: Source = .poloniex
    let sourceInstitutionId: String = ""
    
    var currencyCode: String = ""
    var usernameLabel: String = ""
    var passwordLabel: String = ""
    var name: String = "BITTREX"
    var products: [String] = []
    var type: String = ""
    var url: String? = "https://bittrex.com/api/v1.1/"
    var fields: [Field]
    
    init() {
        let keyField = Field(name: "API Key", type: .key, value: nil)
        let secretField = Field(name: "Secret", type: .secret, value: nil)
        self.fields = [keyField, secretField]
    }
}
