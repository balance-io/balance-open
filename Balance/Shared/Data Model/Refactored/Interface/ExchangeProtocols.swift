//
//  ExchangeApi2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public typealias ExchangeOperationCompletionHandler = (_ success: Bool, _ error: Error?, _ data: Any?) -> Void

public enum TransactionType {
    case unknown
    case deposit
    case withdrawal
    case trade
    case margin
    case fee
    case transfer
    case match
    case rebate
}

public protocol ExchangeApi2 {
    func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation
}

extension ExchangeApi2 {
    func processBaseErrors(response: HTTPURLResponse?, error: Error?) -> Error? {
        if let error = error as NSError?, error.code == -1009 {
            return ExchangeBaseError.internetConnection
        }
        
        guard let statusCode = response?.statusCode else {
            return nil
        }
        
        switch statusCode {
        case 400...499:
            return ExchangeBaseError.invalidCredentials(statusCode: statusCode)
        case 500...599:
            return ExchangeBaseError.invalidServer(statusCode: statusCode)
        default:
            return nil
        }
    }
    
    func createDict(from data: Data?) -> [AnyHashable: Any]? {
        guard let data = data,
            let rawData = try? JSONSerialization.jsonObject(with: data) else {
                return nil
        }
        
        return rawData as? [AnyHashable: Any]
    }
}

protocol OperationResult {
    var responseData: ExchangeOperationCompletionHandler? { get }
    var handler: RequestHandler { get }
}

extension OperationResult {
    func handleResponse(for action: APIAction?, data: Data?, response: URLResponse?, error: Error?) -> Any {
        return handler.handleResponseData(for: action, data: data, error: error, ulrResponse: response)
    }
}
