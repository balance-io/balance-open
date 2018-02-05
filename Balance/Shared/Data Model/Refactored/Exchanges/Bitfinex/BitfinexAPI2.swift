//
//  BitfinexAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/5/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BitfinexAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .post }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .hmac(hmacAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA384), digestLength: Int(CC_SHA384_DIGEST_LENGTH)) }
    override var encondingMessageType: ApiEncondingMessageType { return .concatenate(format: "%02x") }
    
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
            
            guard let messageData = createMessageData(nonce: action.nonce, path: action.path, query: ""),
                let messageSigned = generateMessageSigned(from: messageData, secretKeyEncoded: encondedSecredData) else {
                return nil
            }
            
            var request = URLRequest.init(url: url)
            request.httpMethod = requestMethod.rawValue
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "bfx-apikey")
            request.setValue(messageSigned, forHTTPHeaderField: "bfx-signature")
            request.setValue("\(action.nonce)", forHTTPHeaderField: "bfx-nonce")
            request.setValue("\(requestDataFormat.header.value)", forHTTPHeaderField: requestDataFormat.header.key)
            
            return request
        }
    }
    
}

private extension BitfinexAPI2 {
    
    func encodeSecret(from credentials: Credentials) -> Data? {
        guard let encodedSecretData = credentials.secretKey.data(using: .utf8),
            !credentials.secretKey.isEmpty else {
                print("Unable to turn secret into Data")
                return nil
        }
        
        return encodedSecretData
    }
    
    func createMessageData(nonce: Int64, path: String, query: String) -> Data? {
        let message = "/api/\(path)\(nonce)"
        guard let messageData = message.data(using: .utf8) else {
            print("Message can't be transformed into a data type")
            return nil
        }
        
        return messageData
    }
    
}
