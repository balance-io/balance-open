//
//  APICredentialsComponentsError.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


extension APICredentialsComponents
{
    enum Error: LocalizedError
    {
        case noCredentials
        case invalidSecret(message: String)
        case bodyNotValidJSON
        case dataNotFound(identifier: String)
        case missingPermissions
        case standard(message: String)
        
        var errorDescription: String? {
            switch self {
            case .bodyNotValidJSON:
                return "There was a problem reaching the server."
            case .noCredentials:
                return "Invalid login credentials"
            case .invalidSecret(let message):
                return "Invalid login credentials. Make sure you have right API and Secret pair: \(message)"
            case .dataNotFound(let identifier):
                return "We couldn't reach the server: \(identifier)"
            case .missingPermissions:
                return "Your API key needs more permission, please create a new one with more permissions"
            case .standard(let message):
                return message
            }
        }
    }
}
