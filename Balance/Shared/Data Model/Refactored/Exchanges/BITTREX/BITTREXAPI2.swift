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
            return ExchangeOperation(with: self, request: singleRequest, resultBlock: completion)
        case .transactions(_):
            
            let transactionSyncer = ExchangeTransactionDataSyncer()
            //TODO: insert response handler(parser) into the operation
            return ExchangeTransactionOperation(action: action, dataSyncer: transactionSyncer, requestBuilder: self)
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
    
}

extension BITTREXAPI2: ExchangeTransactionRequest {
    
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

//TODO: Need implement
extension BITTREXAPI2: RequestHandler {
    
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse: URLResponse?) -> Any {
        return "Mock Data"
    }
    
}
