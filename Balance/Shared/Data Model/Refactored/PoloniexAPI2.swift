//
//  PoloniexAPI2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

// This is for example Poloniex
class PoloniexAPI2: AbstractApi {
    override var requestMethod: ApiRequestMethod { return .post }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .hmacSha512 }
    
    override func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data) -> ExchangeError? {
        // In this example, look for 400 or 403 errors and return .invalidCredentials, then look for
        // correct data format and either return .other or nil
        fatalError("not implemented")
    }
    
    override func processData(requestType: ApiRequestType, data: Data) -> Any {
        // Parse the JSON into [PoloniexAccount] or [PoloniexInstitution] depending on request type
        // and return for handling in the completion block by the app
        fatalError("not implemented")
    }
    
    //MARK: Builder methods for Request
    override func createRequest(for action: APIAction) -> URLRequest? {
        
        switch action.type {
        case .accounts, .transactions:
            let message = createMessage(for: action)
            guard let messageSigned = generateMessageSigned(for: action),
                let url = action.url else {
                    return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "Key")
            request.setValue(messageSigned, forHTTPHeaderField: "Sign")
            request.httpBody = message?.data(using: .utf8)
            
            return request
        }
        
    }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.components.query
    }
    
}
