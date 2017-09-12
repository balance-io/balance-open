//
//  GDAXModelError.swift
//  BalanceOpen
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// MARK: Model error

extension GDAXAPIClient {
    enum ModelError: LocalizedError {
        case invalidJSON(json: [String : Any])
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "There was a problem reaching the server."
            }
        }
    }
}


// MARK: APIError

extension GDAXAPIClient {
    enum APIError: LocalizedError {
        case invalidJSON
        case response(httpResponse: HTTPURLResponse, data: Data?)
        
        // MARK: Message
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "Invalid JSON"
            case .response(_, let data):
                guard let unwrappedData = data,
                      let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String : Any],
                      let message = json?["message"] as? String else {
                    return nil
                }
                
                return message
            }
        }
    }
}
