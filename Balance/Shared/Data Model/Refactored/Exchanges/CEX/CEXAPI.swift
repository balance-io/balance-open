//
//  CEXAPI.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/13/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class CEXAPI: AbstractApi {
    override var requestMethod: ApiRequestMethod { return .post }
    override var requestDataFormat: ApiRequestDataFormat { return .json }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha256 }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts, .transactions:
            guard let messageSigned = generateMessageSigned(for: action), let url = action.url,
                var body = action.components?.query else {
                return nil
            }
            body += "&signature=\(messageSigned)"
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            request.httpBody = body.data(using: .utf8)
            
            return request
        }
    }
    
    override func createMessage(for action: APIAction) -> String? {
        return "\(action.nonce)\(action.credentials.userId)\(action.credentials.apiKey)"
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let error = dict["error"] as? String else {
                return nil
        }
        return ExchangeBaseError.other(message: error)
    }
 
    override func buildAccounts(from data: Data) -> Any {
        guard let data = prepareDataForAccounts(from: data) else {
            return ExchangeBaseError.other(message: "CEX Accounts Infor not available")
        }
        
        do {
            let accounts = try JSONDecoder().decode([CEXAccount].self, from: data)
            return accounts
        } catch {
            print("error: \(error)")
            return ExchangeBaseError.other(message: "CEX Accounts Infor not available")
        }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        return []
    }
}

private extension CEXAPI {
    func prepareDataForAccounts(from data: Data) -> Data? {
        guard let info = createDict(from: data) as? [String: AnyObject] else {
            return nil
        }
        let timestamp: String = info["timestamp"] as? String ?? ""
        var accountsDict = [[String: AnyObject]]()
        info.keys.forEach { (key) in
            if var dict = info[key] as? [String: AnyObject] {
                dict["currency"] = key as AnyObject
                dict["timestamp"] = timestamp as AnyObject
                accountsDict.append(dict)
            }
        }
        
        return try? JSONSerialization.data(withJSONObject: accountsDict, options: .prettyPrinted)
    }
}

//TODO: remove this code in future
extension CEXAPI: ExchangeApi {
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {}
}
