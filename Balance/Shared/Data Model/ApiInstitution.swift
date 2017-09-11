//
//  ApiInstitution.swift
//  Balance
//
//  Created by Benjamin Baron on 8/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol ApiInstitution {
    var source: Source { get }
    var sourceInstitutionId: String { get }
    
    var currencyCode: String { get }
    var usernameLabel: String { get }
    var passwordLabel: String { get }
    
    var name: String { get}
    var products: [String] { get }
    
    var type: String { get }
    var url: String? { get }
    
    var fields: [Field] { get }
}

struct Field {
    var name: String
    var label: String
    var type: String
    var value: String?
}
