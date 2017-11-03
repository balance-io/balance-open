//
//  KrakenErrors.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


// MARK: Model error

extension KrakenAPIClient {
    enum ModelError: LocalizedError {
        case invalidJSON(json: Any)
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "There was a problem reaching the server."
            }
        }
    }
}


// MARK: APIError

extension KrakenAPIClient {
    enum APIError: LocalizedError {
        case invalidJSON
        case keysPermissionError
        case response(httpResponse: HTTPURLResponse, data: Data?)
        
        // MARK: Message
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "Invalid JSON"
            case .keysPermissionError:
                return "Your login keys have incorrect permissions"
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
