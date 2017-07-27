//
//  GDAXModelError.swift
//  BalanceOpen
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// MARK: Model error

internal extension GDAXAPIClient
{
    internal enum ModelError: Error
    {
        case invalidJSON(json: [String : Any])
    }
}

// MARK: Credentials error

internal extension GDAXAPIClient
{
    internal enum CredentialsError: Error
    {
        case invalidSecret(message: String)
        case bodyNotValidJSON
        case dataNotFound(identifier: String)
    }
}

internal extension GDAXAPIClient
{
    internal enum APIError: Error
    {
        case invalidJSON
        case response(httpResponse: HTTPURLResponse, json: Any)
    }
}
