//
//  ExchangeManager.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum ManagerState {
    case refresh(source: Source)
    case autenticate(source: Source)
}

protocol ExchangeManagerAction {
    func login(with source: Source, fields: [Field])
    func refresh(institution: Institution)
}

fileprivate typealias ExchangeCallbackResult = (success: Bool, error: Error?, result: [Any])

class ExchangeManager: ExchangeManagerAction {
    
    private lazy var autenticationQueue: OperationQueue = {
        let taskQueue = OperationQueue()
        taskQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        taskQueue.name = "autentication"
        
        return taskQueue
    }()
    
    private lazy var refreshQueue: OperationQueue = {
        let taskQueue = OperationQueue()
        taskQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        taskQueue.name = "refresh"
        
        return taskQueue
    }()
    
    private let keychainService: KeychainServiceProtocol
    private let repositoryService: RepositoryServiceProtocol
    private let urlSession: URLSession
    
    init(urlSession: URLSession? = nil, repositoryService: RepositoryServiceProtocol? = nil, keychainService: KeychainServiceProtocol? = nil) {
        self.urlSession = urlSession ?? certValidatedSession
        self.repositoryService = repositoryService ?? ExchangeRepositoryServiceProvider()
        self.keychainService = keychainService ?? ExchangeKeychainServiceProvider()
    }
    
    func login(with source: Source, fields: [Field]) {
        guard let credentials = credentials(from: fields, source: source) else {
            return
        }
        
        switch source {
        case .poloniex:
            let api = PoloniexAPI2.init(session: urlSession)
            let action = PoloniexApiAction.init(type: .accounts, credentials: credentials)
            let fetchAccountsOperation = api.fetchData(for: action, completion: { [weak self] (success, error, result) in
                let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
                self?.processLoginCallback(callbackResult, source: source, credentials: credentials)
            })
            
            autenticationQueue.addOperation(fetchAccountsOperation)
        default:
            return
        }
    }
    
    func refresh(institution: Institution) {
        
    }
    
}

private extension ExchangeManager {
    
    struct KeychainConstants {
        static let secretKey = "secret"
        static let apiKey = "apiKey"
    }
    
    func processLoginCallback(_ callbackResult: ExchangeCallbackResult, source: Source, credentials: Credentials) {
        switch source {
        case .poloniex:
            processPoloniexLogin(callbackResult, credentials: credentials)
        default:
            return
        }
    }
    
    func processRefreshCallback(_ callbackResult: ExchangeCallbackResult, source: Source, credentials: Credentials) {
        
    }
    
    func processPoloniexLogin(_ callbackResult: ExchangeCallbackResult, credentials: Credentials) {
        guard let institution = repositoryService.createInstitution(for: .poloniex) else {
            print("Error - Can't create institution for poloniex login")
            //TODO: notify state
            return
        }
        
        let result = callbackResult.result
        
        if !result.isEmpty, callbackResult.success {
            
            let poloniexKeychainSecretKeyAccount = "secret institutionId: \(institution.institutionId)"
            keychainService.save(account: poloniexKeychainSecretKeyAccount, key: KeychainConstants.secretKey, value: credentials.secretKey)
            let poloniexKeychainApiKeyAccount = "apiKey institutionId: \(institution.institutionId)"
            keychainService.save(account: poloniexKeychainApiKeyAccount, key: KeychainConstants.secretKey, value: credentials.apiKey)
            
            return
        }
        
        //TODO: validate error like invalid credentials and notify state
        if let error = callbackResult.error as? APIBasicError {
            
        }
    }
    
}

//mark: Credential Helper Methods
private extension ExchangeManager {
    
    func credentials(from fields: [Field], source: Source) -> Credentials? {
        guard fields.count == totalFields(for: source) else {
            print("Error - Invalid amount for creating credentials from fields array")
            return nil
        }
        
        let credentials = BalanceCredentials(fields: fields)
        guard areCredentialsValid(credentials, for: source) else {
            print("Error - Credentials weren't setted correctly for \(source)")
            return nil
        }
        
        return credentials
    }
    
    func areCredentialsValid(_ credentials: Credentials, for source: Source) -> Bool {
        switch source {
        case .poloniex:
            return !credentials.apiKey.isEmpty && !credentials.secretKey.isEmpty
        default:
            return false
        }
    }
    
    func totalFields(for source: Source) -> Int {
        switch source {
        case .poloniex:
            return 2
        default:
            return 2
        }
    }
    
}
