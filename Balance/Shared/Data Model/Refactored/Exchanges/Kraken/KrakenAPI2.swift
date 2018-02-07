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
    override var requestHandler: RequestHandler? { return self }
    
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
    
    override func buildAccounts(from data: Data) -> Any {
        return []
    }
    
     override func buildTransactions(from data: Data) -> Any {
        return []
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        return nil
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

// MARK: Request Handler

extension KrakenAPI2: RequestHandler {
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, ulrResponse: URLResponse?) -> Any {
        guard let action = action else {
            return ExchangeBaseError.other(message: "No action provided")
        }
        
        if let error = processErrors(response: ulrResponse, data: data, error: error) {
            return error
        }
        
        return processData(requestType: action.type, data: data)
    }
}
