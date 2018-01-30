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
    func manageAutenticationCallback(with data: Any, source: Source)
    func refresh(institution: Institution)
}

fileprivate typealias ExchangeCallbackResult = (success: Bool, error: Error?, result: Any?)

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
    
    private lazy var krakenExchangeAPI = { return KrakenAPI2(session: urlSession) }()
    private lazy var poloniexExchangeAPI = { return CoinbaseAPI2(session: urlSession) }()
    private lazy var coinbaseExchangeAPI = { return CoinbaseAPI2(session: urlSession) }()
    
    init(urlSession: URLSession? = nil, repositoryService: RepositoryServiceProtocol? = nil, keychainService: KeychainServiceProtocol? = nil) {
        self.urlSession = urlSession ?? certValidatedSession
        self.repositoryService = repositoryService ?? ExchangeRepositoryServiceProvider()
        self.keychainService = keychainService ?? ExchangeKeychainServiceProvider()
    }
    
    func login(with source: Source, fields: [Field]) {
        guard let credentials = credentials(from: fields, source: source) else {
            return
        }
        
        let exchangeApi: AbstractApi?
        let exchangeAction: APIAction?
        
        switch source {
        case .poloniex:
            exchangeApi = poloniexExchangeAPI
            exchangeAction = PoloniexApiAction.init(type: .accounts, credentials: credentials)
        case .kraken:
            exchangeApi = krakenExchangeAPI
            exchangeAction = KrakenApiAction.init(type: .accounts, credentials: credentials)
        case .coinbase:
            coinbaseExchangeAPI.prepareForAutentication()
            return
        default:
            return
        }
        
        guard let api = exchangeApi, let action = exchangeAction else {
            return
        }
        
        let fetchAccountsOperation = api.fetchData(for: action, completion: { [weak self] (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self?.processLoginCallbackResult(callbackResult, source: source, credentials: credentials)
        })
        
        autenticationQueue.addOperation(fetchAccountsOperation)
    }
    
    func manageAutenticationCallback(with data: Any, source: Source) {
        switch source {
        case .coinbase:
            launchCoinbaseAutentication(with: data)
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
        if let data = callbackResult.result,
            callbackResult.success {
            
            if let transactions = data as? [ExchangeTransaction] {
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
        
        if let data = callbackResult.result,
            callbackResult.success {
            
            if let accounts = data as? [ExchangeAccount] {
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

//mark: Coinbase helper methods
private extension ExchangeManager {
    
    func launchCoinbaseAutentication(with data: Any) {
        let operation = coinbaseExchangeAPI.startAutentication(with: data) { [weak self] (success, error, result) in
            if let coinbaseInstitution = result as? Institution,
                success {
                self?.fetchCoinbaseAccounts(with: coinbaseInstitution)
            }
            
            if let error = error {
                print(error)
                //change state
            }
        }
        
        guard let coinbaseOperation = operation else {
            return
        }
        
        autenticationQueue.addOperation(coinbaseOperation)
    }
    
    func fetchCoinbaseAccounts(with institution: Institution) {
        
    }
    
}

//mark: Poloniex helper methods
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
        guard source != .coinbase else {
            return BalanceCredentials()
        }
        
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
        case .poloniex, .kraken:
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
