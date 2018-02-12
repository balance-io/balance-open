//
//  BinanceAPI.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 2/9/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class BinanceAPI: AbstractApi {
    
    override var requestMethod: ApiRequestMethod { return .get }
    override var requestDataFormat: ApiRequestDataFormat { return .urlEncoded }
    override var requestEncoding: ApiRequestEncoding { return .simpleHmacSha256 }
    
    override func createMessage(for action: APIAction) -> String? {
        return action.query
    }
    
    override func createRequest(for action: APIAction) -> URLRequest? {
        switch action.type {
        case .accounts:
            guard let urlWithoutSignature = action.url,
                let messageSigned = generateMessageSigned(for: action),
                let url = urlWithoutSignature.addQueryParams(url: urlWithoutSignature, newParams: ["signature": messageSigned]) else {
                return nil
            }
            
            return createRequest(from: action, with: url)
        default:
            return nil
        }
    }
    
    override func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation? {
        switch action.type {
        case .accounts:
            guard let singleRequest = createRequest(for: action) else {
                return nil
            }
            
            return ExchangeOperation(with: self, request: singleRequest, resultBlock: completion)
        case .transactions(_):
            let transactionSyncer = ExchangeTransactionDataSyncer()
            
            return ExchangeTransactionOperation(action: action,
                                                dataSyncer: transactionSyncer,
                                                requestBuilder: self,
                                                responseHandler: self,
                                                resultBlock: completion)
        }
    }
    
}

private extension BinanceAPI {
    
    func createRequest(from action: APIAction, with url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.timeoutInterval = 5000
        request.setValue(action.credentials.apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
        
        return request
    }
    
}

extension BinanceAPI: ResponseHandler {
    
    func handleResponseData(for action: APIAction?, data: Data?, error: Error?, urlResponse: URLResponse?) -> Any {
        print(String(data: data ?? Data.init(), encoding: .utf8))
        print(error)
        
        return "Mock response"
    }
    
}

extension BinanceAPI: ExchangeTransactionRequest {
    
    func createTransactionAction(from action: APIAction) -> APIAction {
        return BinanceAPIAction(type: action.type, credentials: action.credentials)
    }
    
    func createRequest(with action: APIAction, for transactionType: ExchangeTransactionType) -> URLRequest? {
        guard let binanceAction = action as? BinanceAPIAction,
            case .transactions(_) = binanceAction.type else {
            return nil
        }
        
        let actionURL =  transactionType == .deposit ?
            binanceAction.depositTransactionURL : binanceAction.withdrawalTransactionURL
        
        guard let urlWithoutSignature = actionURL,
            let query = urlWithoutSignature.query else {
            return nil
        }
        
        let messageSigned = CryptoAlgorithm.sha256.hmac(body: query,
                                                        key: action.credentials.secretKey)
        
        guard let url = urlWithoutSignature.addQueryParams(url: urlWithoutSignature, newParams: ["signature": messageSigned]) else {
            return nil
        }
        
        return createRequest(from: action, with: url)
    }
    
}

//TODO: delete the code below(When new interface is done)
extension BinanceAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
