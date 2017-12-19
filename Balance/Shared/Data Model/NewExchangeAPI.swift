//
//  NewExchangeAPI.swift
//  Balance
//
//  Created by Mac on 12/10/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

typealias ExchangeAPIResult = (object: Any?, error: Error?, institution: Institution?)
typealias ExchangeAPIResultTask = (ExchangeAPIResult) -> Void

fileprivate enum APIResponseKey: String {
    case error
}

enum APIBasicError: LocalizedError {
    case bodyNotValidJSON
    case incorrectLoginCredentials
    case invalidPermissionCredentials
    case dataNotPresented
    case dataWithError(errorDescription: String)
    case repositoryNotCreated(onExchange: Source)
    
    var errorDescription: String? {
        switch self {
        case .bodyNotValidJSON:
            return "There was a problem reaching the server."
        case .incorrectLoginCredentials:
            return "Invalid login credentials. Make sure you have right API and Secret pair."
        case .invalidPermissionCredentials:
            return "Your API key doesn't have enough permisions to perfom this action."
        case .dataNotPresented:
            return "Response not contains any data"
        case .dataWithError(let errorDescription):
            return "Data fetched from server contains error: \(errorDescription)"
        case .repositoryNotCreated(let onExchange):
            return "Repository can't not be created on \(onExchange.description), after pass base validations"
        }
    }
}

protocol NewExchangeApi: class {
    associatedtype Action
    
    func performAction(for action: Action, apiKey: String, secretKey: String, completionBlock: @escaping ExchangeAPIResultTask)
}

extension NewExchangeApi {
    
    func callResultTask(object: Any?, error: Error? = nil, institution: Institution?, completionBlock: @escaping ExchangeAPIResultTask) {
        async {
            let result = ExchangeAPIResult(object: object, error: error, institution: institution)
            completionBlock(result)
        }
    }
    
    func callResultTaskWithError(_ error: Error?, completionBlock: @escaping ExchangeAPIResultTask) {
        async {
            let result = ExchangeAPIResult(object: nil, error: error, institution: nil)
            completionBlock(result)
        }
    }
    
    //Parser Utils
    func createDict(from responseData: Data?) -> [String: AnyObject]? {
        guard let responseData = responseData,
            let rawDict = try? JSONSerialization.jsonObject(with: responseData) else {
                return nil
        }
        
        return rawDict as? [String: AnyObject]
    }
    
    func findErrorMessage(on dict: [String: AnyObject]) -> String? {
        return dict[APIResponseKey.error.rawValue] as? String
    }
    
    func validateBaseAPIErrors(data: Data?, error: Error?, response: URLResponse?, completionBlock: @escaping ExchangeAPIResultTask) -> [String: Any]? {
        guard let response = response as? HTTPURLResponse,
            (response.statusCode != 400 && response.statusCode != 403) else {
                callResultTaskWithError(APIBasicError.incorrectLoginCredentials,
                                        completionBlock: completionBlock)
                return nil
        }
        
        guard let data = data,
            let dict = self.createDict(from: data) else {
                self.callResultTaskWithError(APIBasicError.bodyNotValidJSON,
                                             completionBlock: completionBlock)
                return nil
        }
        
        if let errorMessageOnData = self.findErrorMessage(on: dict) {
            let error = APIBasicError.dataWithError(errorDescription: errorMessageOnData)
            self.callResultTaskWithError(error, completionBlock: completionBlock)
            return nil
        }
        
        return dict
    }
    
}
