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
    
    //let sourceInstitutionId: String = ""
    
    //var currencyCode: String = ""
    //var usernameLabel: String = ""
    //var passwordLabel: String = ""
    
    //var products: [String] = []
    //var type: String = ""
    //var url: String? = "https://poloniex.com/login"
    
    init() {
        let keyField = Field(name: "API Key", type: .key, value: "")
        let secretField = Field(name: "Secret", type: .secret, value: "")
        self.fields = [keyField, secretField]
    }
}
