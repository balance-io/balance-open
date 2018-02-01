//
//  ExchangeManager.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum ExchangeManagerInteractions {
    case autentication
    case refresh
    case refreshToken
}

enum ExchangeManagerState {
    case operationSucceeded(institution: Institution, type: ExchangeManagerInteractions)
    case operationFailed(institution: Institution?, errorDescription: String, type: ExchangeManagerInteractions)
}

protocol ExchangeManagerActions {
    func login(with source: Source, fields: [Field])
    func manageAutenticationCallback(with data: Any, source: Source)
    func refresh(institution: Institution)
    func refreshAccessToken(for institution: Institution)
    func getCredentials(for institution: Institution) -> Credentials?
}

fileprivate typealias ExchangeCallbackResult = (success: Bool, error: Error?, result: Any?)

class ExchangeManager {
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
    private lazy var poloniexExchangeAPI = { return PoloniexAPI2(session: urlSession) }()
    private lazy var coinbaseExchangeAPI = { return CoinbaseAPI2(session: urlSession) }()
    
    init(urlSession: URLSession? = nil, repositoryService: RepositoryServiceProtocol? = nil, keychainService: KeychainServiceProtocol? = nil) {
        self.urlSession = urlSession ?? certValidatedSession
        self.repositoryService = repositoryService ?? ExchangeRepositoryServiceProvider()
        self.keychainService = keychainService ?? ExchangeKeychainServiceProvider()
    }
}


//mark: Common Interface
extension ExchangeManager: ExchangeManagerActions {
    
    func login(with source: Source, fields: [Field]) {
        guard let credentials = BalanceCredentials.credentials(from: fields, source: source) else {
            return
        }
        
        let exchangeApi: AbstractApi?
        let exchangeAction: APIAction?
        
        switch source {
        case .poloniex:
            exchangeApi = poloniexExchangeAPI
            exchangeAction = PoloniexApiAction(type: .accounts, credentials: credentials)
        case .kraken:
            exchangeApi = krakenExchangeAPI
            exchangeAction = KrakenApiAction(type: .accounts, credentials: credentials)
        case .coinbase:
            coinbaseExchangeAPI.prepareForAutentication()
            return
        default:
            return
        }
        
        guard let api = exchangeApi, let action = exchangeAction else { return }
        
        let fetchAccountsOperation = api.fetchData(for: action) { success, error, result in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self.processLoginCallbackResult(callbackResult, source: source, credentials: credentials)
        }
        
        if let fetchAccountsOperation = fetchAccountsOperation {
            autenticationQueue.addOperation(fetchAccountsOperation)
        }

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
        guard let credentials = keychainService.fetchCredentials(with: "\(institution.institutionId)", source: institution.source) else {
            log.debug("Error - Can't refresh \(institution.source.description) institution with id \(institution.institutionId), becuase credentials weren't fetched")
            return
        }
        
        let exchangeApi: AbstractApi?
        let exchangeAccountAction: APIAction?
        let exchangeTransactionAction: APIAction?
        
        switch institution.source {
        case .poloniex:
            exchangeApi = poloniexExchangeAPI
            exchangeAccountAction = PoloniexApiAction(type: .accounts, credentials: credentials)
            exchangeTransactionAction = PoloniexApiAction(type: .transactions(input: nil), credentials: credentials)
        case .kraken:
            exchangeApi = krakenExchangeAPI
            exchangeAccountAction = KrakenApiAction(type: .accounts, credentials: credentials)
            exchangeTransactionAction = KrakenApiAction(type: .transactions(input: nil), credentials: credentials)
        case .coinbase:
            refreshCoinbase(with: institution, credentials: credentials)
            return
        default:
            return
        }
        
        guard let api = exchangeApi,
            let accountAction = exchangeAccountAction,
            let transactionAction = exchangeTransactionAction else {
                return
        }
        
        let refreshAccountsOperation = api.fetchData(for: accountAction) { (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        let refreshTransationOperation = api.fetchData(for: transactionAction) { (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        if let refreshOperation = refreshAccountsOperation, let refreshTransaction = refreshTransationOperation {
            refreshQueue.addOperation(refreshOperation)
            refreshQueue.addOperation(refreshTransaction)
        }

    }
    
    func refreshAccessToken(for institution: Institution) {
        let credentialIdentifier = "\(institution.institutionId)"
        let credentials = keychainService.fetchCredentials(with: credentialIdentifier, source: institution.source)
        guard let oauthCredentials = credentials as? OAUTHCredentials,
            institution.source == .coinbase else {
                return
        }
        
       let coinbaseRefreshTokenOperation = coinbaseExchangeAPI.refreshAccessToken(with: oauthCredentials) { [weak self] (success, error, result) in
            guard let `self` = self else {
                return
            }
            
            if let refreshedCoinbaseCredentials = result as? CoinbaseAutentication ,success {
                self.keychainService.save(source: institution.source, identifier: credentialIdentifier, credentials: refreshedCoinbaseCredentials)
                //TODO: change state before refesh new data
                self.refreshCoinbase(with: institution, credentials: refreshedCoinbaseCredentials)
            }
            
            if self.containsError(error, with: nil) {
                //TODO: change state
            }
        }
        
        guard let refreshTokenOperation = coinbaseRefreshTokenOperation else { return }
        autenticationQueue.addOperation(refreshTokenOperation)
    }
    
    func getCredentials(for institution: Institution) -> Credentials? {
        return keychainService.fetchCredentials(with: "\(institution.institutionId)", source: institution.source)
    }
    
}

//Reponse methods
private extension ExchangeManager {
    
    func processRefreshCallback(_ callbackResult: ExchangeCallbackResult, institution: Institution, credentials: Credentials) {
        if let data = callbackResult.result,
            callbackResult.success {
            
            if let transactions = data as? [ExchangeTransaction] {
                repositoryService.createTransactions(for: institution.source, transactions: transactions, institution: institution)
                //TODO: change state
            }
            
            if let accounts = data as? [ExchangeAccount] {
                
            }
            
            return
        }
        
        if containsError(callbackResult.error, with: institution) {
            //TODO: remove the operation for insitution if there is one pending(account operation, transaction operation)
        }
    }
    
    func processLoginCallbackResult(_ callbackResult: ExchangeCallbackResult, source: Source, credentials: Credentials, institution: Institution? = nil) {
        if let data = callbackResult.result,
            callbackResult.success {
            
            guard let institution = institution ?? repositoryService.createInstitution(for: source) else {
                print("Error - Can't create institution for \(source.description) on login operation")
                //TODO: change state
                return
            }
            
            guard let accounts = data as? [ExchangeAccount] else {
                log.debug("Error - Invalid accounts data for being saved after login")
                //TODO: change state
                return
            }
            
            keychainService.save(source: source, identifier: "\(institution.institutionId)", credentials: credentials)
            repositoryService.createAccounts(for: source, accounts: accounts, institution: institution)
            //TODO: change state
            return
        }
        
        containsError(callbackResult.error, with: nil)
    }
    
    @discardableResult func containsError(_ error: Error?, with institution: Institution?) -> Bool {
        guard let baseError = error as? ExchangeBaseError else {
            return false
        }
        
        guard let institution = institution,
            case .invalidCredentials(_) = baseError else {
            log.debug("Error - Can't refresh data with error \(baseError.localizedDescription)")
            return true
        }
        
        log.debug("Error - Can't refresh data with invalid certificate \(baseError.localizedDescription)")
        institution.passwordInvalid = true
        institution.replace()
        return true
    }
}

// MARK: Coinbase helper methods

private extension ExchangeManager {
    func launchCoinbaseAutentication(with data: Any) {
        let operation = coinbaseExchangeAPI.startAutentication(with: data) { success, error, result in
            if let coinbaseOAUTHCredentials = result as? OAUTHCredentials,
                let coinbaseInstitution = self.repositoryService.createInstitution(for: .coinbase),
                success {
                
                self.fetchCoinbaseAccounts(with: coinbaseInstitution, credentials: coinbaseOAUTHCredentials)
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
    
    func fetchCoinbaseAccounts(with institution: Institution, credentials: OAUTHCredentials) {
        let apiAction = CoinbaseAPI2Action(type: .accounts, credentials: credentials)
        let coinbaseAccountsOperation = coinbaseExchangeAPI.fetchData(for: apiAction) { [weak self] (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self?.processLoginCallbackResult(callbackResult, source: institution.source, credentials: credentials, institution: institution)
        }
        
        if let accountOperation = coinbaseAccountsOperation {
            autenticationQueue.addOperation(accountOperation)
        }

    }
    
    func refreshCoinbase(with institution: Institution, credentials: Credentials) {
        
        let exchangeAccountAction = CoinbaseAPI2Action(type: .accounts, credentials: credentials)
        let refreshAccountsOperation = coinbaseExchangeAPI.fetchData(for: exchangeAccountAction) { [weak self] (success, error, result) in
            let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
            self?.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        if let refreshOperation = refreshAccountsOperation {
            refreshQueue.addOperation(refreshOperation)
        }
        
        let coinbaseAccounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        
        guard !coinbaseAccounts.isEmpty else {
            log.debug("Warning - Can't refresh coinbase institution with \(institution.institutionId) id")
            return
        }
        
        coinbaseAccounts.forEach {
            let exchangeTransactionAction = CoinbaseAPI2Action(type: .transactions(input: $0.sourceAccountId), credentials: credentials)
            let refreshTransationOperation = coinbaseExchangeAPI.fetchData(for: exchangeTransactionAction, completion: { [weak self] (success, error, result) in
                let callbackResult = ExchangeCallbackResult(success: success, error: error, result: result)
                self?.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
            })
            
            if let refreshTransaction = refreshTransationOperation {
                refreshQueue.addOperation(refreshTransaction)
            }

        }
        
    }
}
