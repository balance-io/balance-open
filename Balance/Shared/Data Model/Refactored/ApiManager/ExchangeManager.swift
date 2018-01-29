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
            let locingAction = PoloniexApiAction.init(type: .accounts, credentials: credentials)
            let fetchAccountsOperation = api.fetchData(for: locingAction, completion: { [weak self] (success, error, result) in
                let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
                self?.processLoginCallbackResult(callbackResult, source: source, credentials: credentials)
            })
            
            autenticationQueue.addOperation(fetchAccountsOperation)
        default:
            return
        }
    }
    
    func refresh(institution: Institution) {
        let source = institution.source
        switch source {
        case .poloniex:
            refreshPoloniex(with: institution)
        default:
            return
        }
    }
    
}

private extension ExchangeManager {
    
    func processRefreshCallback(_ callbackResult: ExchangeCallbackResult, institution: Institution, credentials: Credentials) {
        let result = callbackResult.result
        
        if !result.isEmpty, callbackResult.success {
            
            if let transactions = result as? [ExchangeTransaction] {
                repositoryService.createTransactions(for: institution.source, transactions: transactions)
                //TODO: change state using the account result too
            }
            
            return
        }
        
        //TODO: validate error like invalid credentials and change state
        if let error = callbackResult.error as? APIBasicError {
            institution.passwordInvalid = true
            institution.replace()
        }
    }
    
    func processLoginCallbackResult(_ callbackResult: ExchangeCallbackResult, source: Source, credentials: Credentials) {
        guard let institution = repositoryService.createInstitution(for: .poloniex) else {
            print("Error - Can't create institution for poloniex login")
            //TODO: change state
            return
        }
        
        let result = callbackResult.result
        
        if !result.isEmpty, callbackResult.success {
            
            if let accounts = result as? [ExchangeAccount] {
                keychainService.save(source: source, identifier: "\(institution.institutionId)", credentials: credentials)
                repositoryService.createAccounts(for: source, accounts: accounts, institution: institution)
                //TODO: change state
            }
            
            return
        }
        
        //TODO: validate error like invalid credentials and change state
        if let error = callbackResult.error as? APIBasicError {
            
        }
    }
    
}

private extension ExchangeManager {
    
    func refreshPoloniex(with institution: Institution) {
        guard let apiKey = institution.apiKey, let secret = institution.secret else {
            print("Error - Can't refresh poloniex institution without credentials")
            return
        }
        
        let api = PoloniexAPI2.init(session: urlSession)
        let credentials = BalanceCredentials(apiKey: apiKey, secretKey: secret)
        let refreshTransactionAction = PoloniexApiAction(type: .transactions, credentials: credentials)
        
        let refreshTransationOperation = api.fetchData(for: refreshTransactionAction) { [weak self] (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self?.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        let refreshAccountsAction = PoloniexApiAction.init(type: .accounts, credentials: credentials)
        let refreshAccountsOperation = api.fetchData(for: refreshAccountsAction) { [weak self] (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self?.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        refreshQueue.addOperation(refreshAccountsOperation)
        refreshQueue.addOperation(refreshTransationOperation)
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
