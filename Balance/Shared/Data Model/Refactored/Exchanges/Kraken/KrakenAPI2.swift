//
//  KrakenAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/26/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class KrakenAPI2: AbstractApi {
    override var requestMethod: ApiRequestMethod { return .post }
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
            guard let url = action.url,
                let query = action.query,
                let encondedSecretData = encodeSecret(from: action.credentials) else {
                    print("Invalid action: \(action.type), for creating kraken request")
                return nil
            }
            
            guard let messageData = createMessageData(nonce: action.nonce, path: action.path, query: query),
                let messageSigned = generateMessageSigned(from: messageData, secretKeyEncoded: encondedSecretData)else {
                print("Invalid message signed")
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            request.httpBody = query.data(using: .utf8)
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "API-Key")
            request.setValue(messageSigned, forHTTPHeaderField: "API-Sign")
            return request
        }
    }
}

private extension KrakenAPI2 {
    func encodeSecret(from credentials: Credentials) -> Data? {
        guard let encodedSecretData = Data(base64Encoded: credentials.secretKey) else {
            print("Secret is not base64 encoded")
            return nil
        }
        
        return encodedSecretData
    }
    
    func createMessageData(nonce: Int64, path: String, query: String) -> Data? {
        guard let nonceQueryEncoded = ("\(nonce)" + query).sha256 else {
            print("Relative path can not be encoded")
            return nil
        }
        
        guard let pathData = path.data(using: .utf8) else {
            print("Path can not be transformed into a data type")
            return nil
        }
        
        return  pathData + nonceQueryEncoded
    }
}
