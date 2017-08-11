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
        case noCredentials
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
        case response(httpResponse: HTTPURLResponse, data: Data?)
        
        // MARK: Message
        
        internal func message() -> String?
        {
            switch self
            {
            case .invalidJSON:
                return "Invalid JSON"
            case .response(_, let data):
                guard let unwrappedData = data,
                      let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String : Any],
                      let message = json?["message"] as? String else
                {
                    return nil
                }
                
                return message
            }
        }
    }
}
