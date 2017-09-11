//
//  PlaidInstitution.swift
//  Balance
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Institution returned from /institutions or /institutions/longtail
struct PlaidInstitution {
    
    let institutionId: String
    let name: String
    let url: String?
    
    let currencyCode: String
    let usernameLabel: String
    let passwordLabel: String
    
    let hasMfa: Bool
    let mfa: [String]

    let products: [String]

    init(institution: [String: AnyObject]) throws {
        institutionId = try checkType(institution, name: "institution_id")
        name = try checkType(institution, name: "name")
        // Still exists?
        url = institution["url"] as? String
        
        // Still exists?
        if institution["currencyCode"] is String {
            currencyCode = try checkType(institution, name: "currencyCode")
        } else {
            // All main institutions are USD so they don't return a currency code
            currencyCode = "USD"
        }
        let credentials: [String: AnyObject] = try checkType(institution, name: "credentials")
        usernameLabel = try checkType(credentials, name: "username")
        passwordLabel = try checkType(credentials, name: "password")
        
        hasMfa = try checkType(institution, name: "has_mfa")
        mfa = try checkType(institution, name: "mfa")
        
        products = try checkType(institution, name: "products")
    }
}

extension PlaidInstitution: ApiInstitution {
    var source: Source { return .plaid }
    var sourceInstitutionId: String { return institutionId }
    var type: String { return "" }
    var fields: [Field] { return [Field]() }
}
