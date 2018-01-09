//
//  KrakenErrors.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


// MARK: Model error

enum KrakenResponseErrorConstants: String {
    case invalidNonce = "EAPI:Invalid nonce"
}

extension KrakenAPIClient {
    
    enum ModelError: LocalizedError {
        case invalidJSON(json: Any)
        case invalidNonce
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON(let json):
                return "Data is not presented on JSON,\n\(json)"
            case .invalidNonce:
                return "Nonce is not valid."
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .invalidJSON(_):
                return "We are experimenting issues with Kraken services, please try again."
            case .invalidNonce:
                return "We are experimenting issues with Kraken services, please increase the Nonce Window to 15 or create new API key again."
            }
        }
    }
    
    func validateKrakenAPIError(on response: Any) -> LocalizedError? {
        guard let json = response as? [String: Any],
            json["result"] == nil else {
            return nil
        }
        
        guard let errors = json["error"] as? [String],
            let error = errors.first,
            !error.isEmpty else {
            return APIError.invalidJSON
        }
        
        if error == "Invalid key" {
            return APIError.keysPermissionError
        }
        
        if error == KrakenResponseErrorConstants.invalidNonce.rawValue {
            return ModelError.invalidNonce
        }
        
        return APIError.invalidJSON
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
                return "We are experimenting issues with Kraken services, please try later."
            case .keysPermissionError:
                return "Your login keys have incorrect permissions."
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
