//
//  BITTREXAPI2.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/6/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BITTREXAPI2: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha512 }
    
    override func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        switch action.type {
        case .accounts :
            guard let singleRequest = createRequest(for: action) else {
                return nil
            }
            
            //TODO: insert response handler(parser) into the operation
            return ExchangeOperation(with: self, action: action, request: singleRequest, resultBlock: completion)
        case .transactions(_):
            let transactionSyncer = ExchangeTransactionDataSyncer()
            return ExchangeTransactionOperation(action: action,
                                                dataSyncer: transactionSyncer,
                                                requestBuilder: self,
                                                responseHandler: self,
                                                resultBlock: completion)
        }
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts:
            guard let url = action.url,
                let messageSigned = generateMessageSigned(for: action) else {
                    return nil
            }

            return createRequest(url: url, credentials: action.credentials, messageSigned: messageSigned)
        default:
            return nil
        }
    }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.url?.absoluteString
    }
    
    override func processApiErrors(from data: Data) -> Error? {
        guard let info = createDict(from: data) as? [String:AnyObject],
            let success = info["success"] as? Bool, !success,
            let message = info["message"] as? String else {
                return nil
        }
        
        return ExchangeBaseError.other(message: message)
    }
 
    override func buildAccounts(from data: Data) -> Any {
        guard let data = prepareData(from: data) else {
            return ExchangeBaseError.other(message: "BITTREX accounts data unavailable")
        }
        
        do {
            return try JSONDecoder().decode([BITTREXAccount2].self, from: data)
        } catch {
            print("error: \(error)")
            return ExchangeBaseError.other(message: "BITTREX accounts data unavailable")
        }
    }
    
    override func buildTransactions(from data: Data) -> Any {
        guard let data = prepareData(from: data) else {
            return ExchangeBaseError.other(message: "BITTREX transactions data unavailable")
        }
        
        do {
            return try JSONDecoder().decode([BITTREXTransaction2].self, from: data)
        } catch {
            print("error: \(error)")
            return ExchangeBaseError.other(message: "BITTREX transactions data unavailable")
        }
    }
}

private extension BITTREXAPI2 {
    func prepareData(from data: Data) -> Data? {
        guard let dict = createDict(from: data) as? [String: AnyObject],
            let data = dict["result"] as? [Any], data.count > 0  else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    }
}

extension BITTREXAPI2: ExchangeTransactionRequest {
    
    func createTransactionAction(from action: APIAction) -> APIAction {
        return BITTREXAPI2Action(type: action.type, credentials: action.credentials)
    }
    
    func createRequest(with action: APIAction, for transactionType: ExchangeTransactionType) -> URLRequest? {
        guard let bittrexAction = action as? BITTREXAPI2Action,
            case .transactions(_) = bittrexAction.type else {
            return nil
        }
        
        let url = transactionType == .deposit ?
            bittrexAction.depositTransactionURL : bittrexAction.withdrawalTransactionURL
        
        guard let transactionURL = url else {
            return nil
        }
        
        let messageSigned = CryptoAlgorithm.sha512.hmac(body: transactionURL.absoluteString,
                                                        key: action.credentials.secretKey)
    
        return createRequest(url: transactionURL, credentials: action.credentials, messageSigned: messageSigned)
    }
    
    private func createRequest(url: URL, credentials: Credentials, messageSigned: String) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.setValue(messageSigned, forHTTPHeaderField: "apisign")

        return (request)
    }
    
}
