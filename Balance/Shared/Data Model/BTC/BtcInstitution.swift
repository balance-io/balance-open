//
//  BtcInstitution.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 30/01/2018.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BtcInstitution: ApiInstitution {
    let source: Source = .blockchain
    let sourceInstitutionId: String = ""
    
    var currencyCode: String = ""
    var usernameLabel: String = ""
    var passwordLabel: String = ""
    var name: String = "Bitcoin Address"
    var products: [String] = []
    var type: String = ""
    var url: String? = "https://blockchain.info"
    var fields: [Field]
    
    init() {
        let addressField = Field(name: "Public Address", type: .address, value: nil)
        let nameField = Field(name: "Name", type: .name, value: nil)
        self.fields = [nameField, addressField]
    }
}
