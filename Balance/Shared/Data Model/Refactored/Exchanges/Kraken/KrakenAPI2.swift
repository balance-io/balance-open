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
    override var requestEncoding: ApiRequestEncoding { return .hmac(hmacAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA512), digestLength: Int(CC_SHA512_DIGEST_LENGTH)) }
    override var encondingMessageType: ApiEncondingMessageType { return .base64 }
    override var responseHandler: ResponseHandler? { return self }
    
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
        guard let dict = preprocessData(from: data) else {
            return []
        }
        
        var accounts: [KrakenAccount2] = []
        dict.forEach { (currency, balance) in
            let account = KrakenAccount2(currency: currency, balance: balance)
            accounts.append(account)
        }
        
        return accounts
    }
    
     override func buildTransactions(from data: Data) -> Any {
        guard let data = prepareTransactionsData(from: data),
            let transactions = try? JSONDecoder().decode([KrakenTransaction2].self, from: data) else {
                return ExchangeBaseError.other(message: "malformed payload")
        }
        
        return transactions
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let errorArray = dict["error"] as? [String],
            let error = errorArray.first else {
                return nil
        }

        switch error {
        case "Invalid key":
            return ExchangeBaseError.invalidCredentials(statusCode: 0)
        case "EAPI:Invalid nonce":
            return ExchangeBaseError.other(message: "Invalid nonce")
        default:
            return ExchangeBaseError.other(message: error)
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
    
    func preprocessData(from data: Data) -> [String: String]? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let resultDict = dict["result"] as? [String: String] else {
                return nil
        }
        
        return resultDict
    }
    
    func prepareTransactionsData(from data: Data) -> Data? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let resultDict = dict["result"] as? [String: AnyObject],
            let ledgerDict = resultDict["ledger"] as? [String: AnyObject] else {
                return nil
        }

        let flatDict = ledgerDict.map { (key, value) -> [String : AnyObject] in
            if var dict = value as? [String: AnyObject] {
                dict["ledgerId"] = key as AnyObject
                return dict
            }
            return [:]
        }
        
        return try? JSONSerialization.data(withJSONObject: flatDict, options: .prettyPrinted)
    }
}

// MARK: Request Handler

extension KrakenAPI2: ResponseHandler {
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse: URLResponse?) -> Any {
        guard let action = action else {
            return ExchangeBaseError.other(message: "No action provided")
        }
        
        if let error = processErrors(response: urlResponse, data: data, error: error) {
            return error
        }
        
        return processData(requestType: action.type, data: data)
    }
}
