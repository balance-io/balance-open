//
//  BITTREXApi.swift
//  Balance
//
//  Created by Mac on 12/9/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Security

class BITTREXApi: NewExchangeApi, ExchangeApi {
    
    private var apiKey: String = ""
    private var secretKey: String = ""
    private let dataBuilder = BITTREXDataBuilder()
    private let urlSession: URLSession
    private let institutionRepository: InstitutionRepository
    
    let source = Source.bittrex
    
    init(urlSession: URLSession? = nil, institutionRepository: InstitutionRepository? = nil) {
        self.urlSession = urlSession ?? certValidatedSession
        self.institutionRepository = institutionRepository ?? InstitutionRepository.si
    }
    
    func authenticationChallenge(loginStrings: [Field], existingInstitution: Institution?, closeBlock: @escaping (Bool, Error?, Institution?) -> Void) {
        //This should be removed by the new ExchangeApi Protocol
    }
    
    func performAction(for action: BITTREXApiAction, apiKey: String, secretKey: String, completionBlock: @escaping ExchangeAPIResultTask) {
        guard let request = createRequest(for: action, apiKey: apiKey, secretKey: secretKey) else {
            return callResultTaskWithError(APIBasicError.incorrectLoginCredentials, completionBlock: completionBlock)
        }
        
        let dataTask = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            guard let `self` = self else { return }
            guard let dict = self.validateBaseAPIErrors(data: data,
                                                        error: error,
                                                        response: response,
                                                        completionBlock: completionBlock) else {
                                                            return
            }
            
            self.validateResponseDict(for: action, dict: dict, completionBlock: completionBlock)
        }
        
        dataTask.resume()
    }

    func validateResponseDict(for action: BITTREXApiAction, dict: [String: Any], completionBlock: @escaping ExchangeAPIResultTask) {
        let (BITTREXApiResult, error) = self.validateBITTREXResponseErrors(on: dict)
        
        if BITTREXApiResult == nil, error == nil {
            callResultTask(object: nil, institution: nil, completionBlock: completionBlock)
            return
        }
        
        if let error = error {
            callResultTaskWithError(error, completionBlock: completionBlock)
            return
        }
        
        guard let result = BITTREXApiResult,
            let resultData = try? JSONSerialization.data(withJSONObject: result) else {
                callResultTaskWithError(BITTREXApiError.resultRawData,
                                             completionBlock: completionBlock)
                return
        }
        
        self.handleResultData(for: action,
                              data: resultData,
                              completionBlock: completionBlock)
    }
    
    func handleResultData(for action: BITTREXApiAction, data: Data, completionBlock: @escaping ExchangeAPIResultTask) {
        
        guard let object = handleResponseObject(for: action, with: data) else {
            return callResultTaskWithError(APIBasicError.dataNotPresented, completionBlock: completionBlock)
        }
        
        guard let institution = institutionRepository.institution(source: source,
                                                                  sourceInstitutionId: "",
                                                                  name: source.description) else {
                                                                    let error = APIBasicError.repositoryNotCreated(onExchange: source)
                                                                    callResultTaskWithError(error, completionBlock: completionBlock)
                                                                    return
        }
        
        institution.apiKey = apiKey
        institution.secret = secretKey
        callResultTask(object: object, institution: institution, completionBlock: completionBlock)
    }
    
}

//mark: Request Methods
private extension BITTREXApi {
    
    func query(for action: BITTREXApiAction, apiKey: String) -> String? {
        let params = action.params(for: action, apiKey: apiKey)
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        
        var components = URLComponents()
        components.queryItems = queryItems
        
        return components.query
    }
    
    func createURI(for action: BITTREXApiAction, apiKey: String, secretKey: String) -> String? {
        guard let query = query(for: action, apiKey: apiKey) else {
            return nil
        }
        
        return "\(action.fullPath)?\(query)"
    }
    
    func createRequest(for action: BITTREXApiAction, apiKey: String, secretKey: String) -> URLRequest? {
        guard let URI = createURI(for: action, apiKey: apiKey, secretKey: secretKey),
            let url = URL(string: URI) else {
                return nil
        }
        
        let signedURI = CryptoAlgorithm.sha512.hmac(body: URI, key: secretKey)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(signedURI, forHTTPHeaderField: "apisign")
        
        return request
    }
    
}

//mark: Handler Response Methods
private extension BITTREXApi {
    
    enum BITTREXResponseConstants: String {
        case message
        case result
        case success
    }
    
    func validateBITTREXResponseErrors(on dict: [String: Any]) -> (result: Any?, error: Error?) {
        if let success = dict[BITTREXResponseConstants.success.rawValue] as? Bool
            ,success {
            
            if let collectionResult = dict[BITTREXResponseConstants.result.rawValue] as? [[String: Any]],
                !collectionResult.isEmpty {
                return (result: collectionResult, error: nil)
            }
            
            if let objectResult = dict[BITTREXResponseConstants.result.rawValue] as? [String: Any],
                !objectResult.isEmpty {
                return (result: objectResult, error: nil)
            }
            
        }
        
        if let message = dict[BITTREXResponseConstants.message.rawValue] as? String,
            !message.isEmpty {
            return (result: nil, error: BITTREXApiError.message(errorDescription: message))
        }
        
        return (result: nil, error: nil)
    }
    
    func handleResponseObject(for action: BITTREXApiAction, with data: Data) -> Any? {
        switch action {
        case .getBalances, .getBalance(_):
            let balances = dataBuilder.createBalances(from: data)
            guard !balances.isEmpty else {
                return nil
            }
            
            return balances
        case .getCurrencies:
            let currencies = dataBuilder.createCurrencies(from: data)
            guard !currencies.isEmpty else {
                    return nil
            }
            
            return currencies
        }
    }
    
}
