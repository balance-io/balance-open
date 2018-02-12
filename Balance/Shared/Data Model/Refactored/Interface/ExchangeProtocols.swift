//
//  ExchangeApi2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public typealias ExchangeOperationCompletionHandler = (_ success: Bool, _ error: Error?, _ data: Any?) -> Void

public protocol ExchangeApi2 {
    func fetchData(for action: APIAction, completion: @escaping ExchangeOperationCompletionHandler) -> Operation?
}

extension ExchangeApi2 {
    
    func createDict(from data: Data?) -> [AnyHashable: Any]? {
        guard let data = data,
            let rawData = try? JSONSerialization.jsonObject(with: data) else {
                return nil
        }
        
        return rawData as? [AnyHashable: Any]
    }
    
    func createArray(from data: Data?) -> [Any]? {
        guard let data = data,
            let rawData = try? JSONSerialization.jsonObject(with: data) else {
                return nil
        }
        
        return rawData as? [Any]
    }
}

protocol OperationResult {
    var resultBlock: ExchangeOperationCompletionHandler { get }
    var handler: ResponseHandler { get }
}

extension OperationResult {
    func handleResponse(for action: APIAction?, data: Data?, response: URLResponse?, error: Error?) -> Any {
        return handler.handleResponseData(for: action, data: data, error: error, urlResponse: response)
    }
}
