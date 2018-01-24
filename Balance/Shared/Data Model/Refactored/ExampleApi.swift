//
//  ExampleApi.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

// This is for example Poloniex
class PoloniexExampleApi: AbstractApi {
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
}

