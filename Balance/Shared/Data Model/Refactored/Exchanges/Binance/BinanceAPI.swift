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
    override var responseHandler: ResponseHandler? { return self }
    
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
            
            var request = URLRequest(url: url)
            request.httpMethod = requestMethod.rawValue
            request.timeoutInterval = 5000
            request.setValue(action.credentials.apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
            
            return request
        case .transactions(_):
            return nil
        }
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

        
        return nil
    }
    
}

//TODO: delete the code below(When new interface is done)
extension BinanceAPI: ExchangeApi {
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //Not needed when the new refactor has been finished!!!!
    }
    
}
