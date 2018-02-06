//
//  BTCAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BTCAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .none }
    override var encondingMessageType: ApiEncondingMessageType { return .none }
    
    override func processErrors(response: URLResponse?, data: Data?, error: Error?) -> Error?  {
        // In this example, look for 400 or 403 errors and return .invalidCredentials, then look for
        // correct data format and either return .other or nil
        fatalError("not implemented")
    }
    
    override func processData(requestType: ApiRequestType, data: Data) -> Any {
        // Parse the JSON into [PoloniexAccount] or [PoloniexInstitution] depending on request type
        // and return for handling in the completion block by the app
        fatalError("not implemented")
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts, .transactions:
            guard let url = action.url else {
                print("Invalid action: \(action.type), for creating Ethplorer request")
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            return request
        }
    }
    
}
