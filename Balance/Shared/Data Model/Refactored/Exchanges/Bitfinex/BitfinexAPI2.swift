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
    override var requestHandler: RequestHandler? { return self }
    
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
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "bfx-apikey")
            request.setValue(messageSigned, forHTTPHeaderField: "bfx-signature")
            request.setValue("\(action.nonce)", forHTTPHeaderField: "bfx-nonce")
            request.setValue("\(requestDataFormat.header.value)", forHTTPHeaderField: requestDataFormat.header.key)
            
            return request
        }
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        if let errorDict = createDict(from: data) as? [String: AnyObject],
            let message = errorDict["message"] as? String {
            return ExchangeBaseError.other(message: message)
        }
        
        guard let JSONArray = createArray(from: data) else {
            return ExchangeBaseError.other(message: "Invalid response")
        }
        
        // array count: 5 for accounts, 22 for transactions
        guard let array = JSONArray.first as? [Any], array.count == 5 || array.count == 22 else {
            return ExchangeBaseError.other(message: "Invalid JSON")
        }
        
        return nil
    }
    
    override func buildAccounts(from data: Data) -> Any {
        guard let array = createArray(from: data)  else {
            return []
        }
        
        return array.flatMap{ createAccounts($0) }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        guard let array = createArray(from: data)  else {
            return []
        }
        
        return array.flatMap{ createTransactions($0) }
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
    
    func createMessageData(nonce: Int64, path: String) -> Data? {
        let message = "/api/\(path)\(nonce)"
        guard let messageData = message.data(using: .utf8) else {
            print("Message can't be transformed into a data type")
            return nil
        }
        
        return messageData
    }
    
    func createAccounts(_ data: Any) -> BitfinexAccount2? {
        guard let data = data as? [Any],
            let type = data[0] as? String,
            let currencyCode = data[1] as? String,
            let balance = data[2] as? Double,
            let unsettledInterest = data[3] as? Double else {
                return nil
        }
        
        let currency: Currency = Currency.rawValue(currencyCode)
        
        // Optional
        let available: Double? = data[4] as? Double
    
        return BitfinexAccount2(type: type, currency: currency, balance: balance, unsettledInterest: unsettledInterest, available: available)
    }
    
    func createTransactions(_ data: Any) -> BitfinexTransaction2? {
        guard let data = data as? [Any],
            let currencyCode = data[1] as? String,
            let address = data[16] as? String,
            let status = data[9] as? String,
            let amount = data[12] as? Double,
            let createdAt = data[6] as? Double,
            let updatedAt = data[5] as? Double else {
                return nil
        }
        
        let currency: Currency = Currency.rawValue(currencyCode)
        
        return BitfinexTransaction2(currency: currency, address: address, status: status, amount: amount, createdAt: createdAt, updatedAt: updatedAt)
    }
    
}

extension BitfinexAPI2: RequestHandler {
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
