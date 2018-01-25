//
//  ExampleApi.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

// This is for example Poloniex
class NewPoloniexAPI: AbstractApi {
    override var requestMethod: ApiRequestMethod { return .post }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .hmac512 }
    
    override func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data?, error: Error?) -> Error? {

        if let error = processBaseErrors(response: response, error: error) {
            return error
        }
        
        if let dict = dataToJSON(data: data) {
            return nil
        }
        
        return nil
    }
    
    override func processData(requestType: ApiRequestType, data: Data) -> [Any] {
        // Parse the JSON into [PoloniexAccount] or [PoloniexInstitution] depending on request type
        // and return for handling in the completion block by the app
        fatalError("not implemented")
    }
    
    func buildObject(from data: Data, and type: ApiRequestType) -> [Any] {
        return type == .accounts ? buildAccounts(from: data) : buildTransacionts(from: data)
    }
}

private extension NewPoloniexAPI {
    
    func buildTransacionts(from data: Data) -> [Any] {
        guard let transactions = try? JSONDecoder().decode([NewPoloniexTransaction].self, from: data) else {
            return []
        }
        
        return transactions
    }
    
    func buildAccounts(from data: Data) -> [Any] {
        guard let accounts = try? JSONDecoder().decode([NewPoloniexAccount].self, from: data) else {
            return []
        }
        
        return accounts
    }
    
}
