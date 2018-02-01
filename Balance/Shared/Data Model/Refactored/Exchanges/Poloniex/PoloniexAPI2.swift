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

    override func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data?, error: Error?) -> Error? {
        
        if let error = processBaseErrors(response: response, error: error) {
            return error
        }
        
        if let _ = createDict(from: data) {
            return nil
        }
        
        return nil
    }
    
    override func processData(requestType: ApiRequestType, data: Data) -> [Any] {
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
    
    class func buildObject(from data: Data, for type: ApiRequestType) -> [Any] {
        return type == .accounts ? buildAccounts(from: data) : buildTransacionts(from: data)
    }
}

private extension PoloniexAPI2 {
    
    class func buildTransacionts(from data: Data) -> [Any] {
        guard let transactions = try? JSONDecoder().decode([NewPoloniexTransaction].self, from: data) else {
            return []
        }
        
        return transactions
    }
    
    class func buildAccounts(from data: Data) -> [Any] {
        guard let accounts = try? JSONDecoder().decode([NewPoloniexAccount].self, from: data) else {
            return []
        }
        
        return accounts
    }
}
