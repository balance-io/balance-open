//
//  GDAXAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/5/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class GDAXAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .hmac(hmacAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA256), digestLength: Int(CC_SHA256_DIGEST_LENGTH)) }
    override var encondingMessageType: ApiEncondingMessageType { return .base64 }
    
    override func processErrors(requestType: ApiRequestType, response: HTTPURLResponse, data: Data?, error: Error?) -> Error?  {
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
        case .accounts, .transactions(_):
            guard let url = action.url,
                let encondedSecredData = encodeSecret(from: action.credentials) else {
                    return nil
            }
            
            guard let messageData = createMessageData(nonce: action.nonce, path: action.path),
                let messageSigned = generateMessageSigned(from: messageData, secretKeyEncoded: encondedSecredData) else {
                    return nil
            }
            
            var request = URLRequest.init(url: url)
            request.httpMethod = requestMethod.rawValue
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "CB-ACCESS-KEY")
            request.setValue(messageSigned, forHTTPHeaderField:"CB-ACCESS-SIGN")
            request.setValue("\(action.nonce)", forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
            request.setValue(action.credentials.passphrase, forHTTPHeaderField: "CB-ACCESS-PASSPHRASE")
            
            return request
        }
    }
    
}

private extension GDAXAPI2 {
    
    func encodeSecret(from credentials: Credentials) -> Data? {
        guard let encondedSecret = Data.init(base64Encoded: credentials.secretKey) else {
            print("Secret is not base64 encoded")
            return nil
        }
        
        return encondedSecret
    }
    
    func createMessageData(nonce: Int64, path: String) -> Data? {
        let message = "\(nonce)\(requestMethod.rawValue)\(path)"
        
        guard let messageData = message.data(using: .utf8) else {
            print("Can't create data from message")
            return nil
        }
        
        return messageData
    }
    
}
