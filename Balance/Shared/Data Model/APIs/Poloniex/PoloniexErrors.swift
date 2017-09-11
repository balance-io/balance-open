//
//  PoloniexErrors.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension PoloniexApi {
    enum CredentialsError: LocalizedError {
        case bodyNotValidJSON
        case incorrectLoginCredentials
        case invalidPermissionCredentials
    
        var errorDescription: String? {
            switch self {
            case .bodyNotValidJSON:
                return "There was a problem reaching the server."
            case .incorrectLoginCredentials:
                return "Invalid login credentials. Make sure you have right API and Secret pair."
            case .invalidPermissionCredentials:
                return "Your API key doesn't have enough permisions to perfom this action."
            }
        }
    }
}
