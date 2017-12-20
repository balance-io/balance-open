//
//  CoinbaseInstitution.swift
//  Balance
//
//  Created by Benjamin Baron on 10/7/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class CoinbaseInstitution: ApiInstitution {
    let source: Source = .coinbase
    let sourceInstitutionId: String = ""
    
    var currencyCode: String = ""
    var usernameLabel: String = ""
    var passwordLabel: String = ""
    var name: String = "Coinbase"
    var products: [String] = []
    var type: String = ""
    var url: String? = "https://coinbase.com"
    var fields: [Field]
    
    init() {
        let keyField = Field(name: "Key", type: .key, value: nil)
        let secretField = Field(name: "Secret", type: .secret, value: nil)
        self.fields = [keyField, secretField]
    }
}
