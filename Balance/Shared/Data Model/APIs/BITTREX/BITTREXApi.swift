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
        assert(loginStrings.count == 2, "number of auth fields should be 2 for Bittrex")
        var secretField : String?
        var keyField : String?
        for field in loginStrings {
            if field.type == .key {
                keyField = field.value
            } else if field.type == .secret {
                secretField = field.value
            } else {
                assert(false, "wrong fields are passed into the Bittrex auth, we require secret and key fields and values")
            }
        }
        guard let secret = secretField, let key = keyField else {
            assert(false, "wrong fields are passed into the Bittrex auth, we require secret and key fields and values")
            
            closeBlock(false, "wrong fields are passed into the Bittrex auth, we require secret and key fields and values", nil)
            return
        }
        
        var institution: Institution? = existingInstitution
        performAction(for: .getBalances, apiKey: key, secretKey: secret) { result in
            guard result.error == nil else {
                async {
                    closeBlock(false, result.error, institution)
                }
                return
            }
            
            institution = existingInstitution ?? InstitutionRepository.si.institution(source: .bittrex, sourceInstitutionId: "", name: "Bittrex")
            institution?.apiKey = key
            institution?.secret = secret
            if let existingInstitution = existingInstitution {
                existingInstitution.passwordInvalid = false
                existingInstitution.replace()
            }
            
            guard let unwrappedInstitution = institution else {
                async {
                    closeBlock(false, BalanceError.databaseError, nil)
                }
                return
            }
            
            // Try to parse the Balances. Normally we would throw an error if this failed, but
            // Bittrex can return 0 records here if you have no accounts, so we only check if there
            // was an API error, otherwise we consider it success.
            guard let balances = result.object as? [BITTREXBalance] else {
                async {
                    closeBlock(true, nil, institution)
                }
                return
            }
            
            for balance in balances {
                let currentBalance = paddedInteger(for: balance.balance, currencyCode: balance.currency)
                let availableBalance = currentBalance
                
                // Initialize an Account object to insert the record
                AccountRepository.si.account(institutionId: unwrappedInstitution.institutionId, source: unwrappedInstitution.source, sourceAccountId: balance.currency, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: balance.currency, currency: balance.currency, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
            }
            
            async {
                closeBlock(true, nil, institution)
            }
        }
    }
    
    func performAction(for action: BITTREXApiAction, apiKey: String, secretKey: String, completionBlock: @escaping ExchangeAPIResultTask) {
        guard let request = createRequest(for: action, apiKey: apiKey, secretKey: secretKey) else {
            return callResultTaskWithError(APIBasicError.incorrectLoginCredentials, completionBlock: completionBlock)
        }
        
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
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
        
        callResultTask(object: object, institution: nil, completionBlock: completionBlock)
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
        if let success = dict[BITTREXResponseConstants.success.rawValue] as? Bool, success {
            
            if let collectionResult = dict[BITTREXResponseConstants.result.rawValue] as? [[String: Any]],
                !collectionResult.isEmpty {
                return (result: collectionResult, error: nil)
            }
            
            if let objectResult = dict[BITTREXResponseConstants.result.rawValue] as? [String: Any],
                !objectResult.isEmpty {
                return (result: objectResult, error: nil)
            }
            
        }
        
        if let message = dict[BITTREXResponseConstants.message.rawValue] as? String, !message.isEmpty {
            if message == "APIKEY_INVALID" || message == "INVALID_SIGNATURE" {
                return (result: nil, error: BITTREXApiError.invalidCredentials)
            }
            
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
        case .getAllDepositHistory, .getDepositHistory(_):
            let deposits = dataBuilder.createDeposits(from: data)
            guard !deposits.isEmpty else {
                return nil
            }
            
            return deposits
        case .getAllWithdrawalHistory, .getWithdrawalHistory(_):
            let withdrawals = dataBuilder.createWithdrawals(from: data)
            guard !withdrawals.isEmpty else {
                return nil
            }
            
            return withdrawals
        }
    }
    
}
