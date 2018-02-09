//
//  BinanceAPI.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BinanceAPI: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha256 }
    override var requestHandler: RequestHandler? { return self }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.query
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts, .transactions(_):
            guard let urlWithoutSignature = action.url,
                let messageSigned = generateMessageSigned(for: action),
                let url = urlWithoutSignature.addQueryParams(url: urlWithoutSignature, newParams: ["signature": messageSigned]) else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 5000
            request.httpBody = messageSigned.data(using: .utf8)
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
            
            return request
        }
    }
    
}

extension BinanceAPI: RequestHandler {
    
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse: URLResponse?) -> Any {
        print(String(data: data ?? Data.init(), encoding: .utf8))
        print(error)
        
        return "Mock response"
    }
    
}

//TODO: delete the code below(When new interface is done)
extension BinanceAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
