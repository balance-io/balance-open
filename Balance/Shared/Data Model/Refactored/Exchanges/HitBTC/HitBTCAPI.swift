//
//  HitBTCAPI.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/11/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class HitBTCAPI: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .baseAuthentication }
    override var responseHandler: ResponseHandler? { return self }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts, .transactions(_):
            guard let url = action.url,
                let baseCredentials = encodeCredentialsWithBaseAuthentication(with: action) else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.setValue(baseCredentials.value, forHTTPHeaderField: baseCredentials.header)
            request.httpMethod = requestMethod.rawValue
            
            return request
        }
    }
    
}

extension HitBTCAPI: ResponseHandler {
    
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse: URLResponse?) -> Any {
        print(String(data: data ?? Data.init(), encoding: .utf8))
        print(error)
        
        return "Mock response"
    }
    
}

//TODO: delete the code below(When new interface is done)
extension HitBTCAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
