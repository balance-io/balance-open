//
//  KucoinAPI.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/13/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class KucoinAPI: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .hmac(hmacAlgorithm: CCHmacAlgorithm(kCCHmacAlgSHA256), digestLength: Int(CC_SHA256_DIGEST_LENGTH)) }
    override var encondingMessageType: ApiEncondingMessageType { return .concatenate(format: "%02x") }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        
        switch action.type {
        case .accounts, .transactions(_):
            guard let url = action.url,
                let encondedSecredData = encodeSecret(from: action.credentials) else {
                    return nil
            }
            
            guard let messageData = createMessageData(nonce: action.nonce, path: action.path, query: action.query ?? ""),
                let messageSigned = generateMessageSigned(from: messageData, secretKeyEncoded: encondedSecredData) else {
                    return nil
            }
            
            var request = URLRequest.init(url: url)
            request.httpMethod = requestMethod.rawValue
            request.timeoutInterval = 3000
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "KC-API-KEY")
            request.setValue(String(action.nonce), forHTTPHeaderField: "KC-API-NONCE")
            request.setValue(messageSigned, forHTTPHeaderField: "KC-API-SIGNATURE")
            
            return request
        }
        
    }
    
    override func buildAccounts(from data: Data) -> Any {
        do {
            let data = try JSONDecoder().decode(KucoinAccounts.self, from: data)
            
            return data.accounts
        } catch {
            print("Accounts from kucoin can not be parsed to an object\n\(error)")
            return []
        }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        do {
            let data = try JSONDecoder().decode(KucoinTransactions.self, from: data)
            
            return data.transactions.filter { $0.status == .success }
        } catch {
            print("Transactions from kucoin can not be parsed to an object\n\(error)")
            return []
        }
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        return nil
    }
    
}

private extension KucoinAPI {
    
    func encodeSecret(from credentials: Credentials) -> Data? {
        guard let encodedSecretData = credentials.secretKey.data(using: .utf8),
            !credentials.secretKey.isEmpty else {
                print("Unable to turn secret into Data")
                return nil
        }
        
        return encodedSecretData
    }
    
    func createMessageData(nonce: Int64, path: String, query: String) -> Data? {
        let message = "\(path)/\(nonce)/\(query)"
        guard let messageData = message.data(using: .utf8) else {
            print("Message can't be transformed into a data type")
            return nil
        }
        
        return messageData.base64EncodedData()
    }
    
}

//TODO: delete the code below(When new interface is done)
extension KucoinAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
