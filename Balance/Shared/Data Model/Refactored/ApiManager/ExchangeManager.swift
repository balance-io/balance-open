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

fileprivate typealias ExchangeManagerCallbackResult = (success: Bool, error: Error?, result: Any?)
fileprivate typealias ExchangeManagerRefreshAction = (api: AbstractApi, accountAction: APIAction, transactionAction: APIAction?)

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
    private lazy var ethploreExchangeAPI = { return EthplorerAPI2(session: urlSession) }()
    private lazy var bitfinexExchangeAPI = { return BitfinexAPI2(session: urlSession) }()
    private lazy var gdaxExchangeAPI = { return GDAXAPI2(session: urlSession) }()
    private lazy var btcExchangeAPI = { return BTCAPI2(session: urlSession) }()
    
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
            print("Invalid credentials for login")
            return
        }
        
        switch source {
        case .coinbase:
            coinbaseExchangeAPI.prepareForAutentication()
        default:
            guard let loginOperation = loginAction(from: source, with: credentials) else {
                return
            }
            
            autenticationQueue.addOperation(loginOperation)
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
        guard let credentials = keychainService.fetchCredentials(with: "\(institution.institutionId)", source: institution.source, name: institution.name) else {
            log.debug("Error - Can't refresh \(institution.source.description) institution with id \(institution.institutionId), becuase credentials weren't fetched")
            return
        }
        
        let refreshAction: ExchangeManagerRefreshAction?
        
        switch institution.source {
        case .poloniex:
            let accountAction = PoloniexApiAction(type: .accounts, credentials: credentials)
            let transactionAction = PoloniexApiAction(type: .transactions(input: nil), credentials: credentials)
            refreshAction = (poloniexExchangeAPI, accountAction, transactionAction)
        case .kraken:
            let accountAction = KrakenApiAction(type: .accounts, credentials: credentials)
            let transactionAction = KrakenApiAction(type: .transactions(input: nil), credentials: credentials)
            refreshAction = (krakenExchangeAPI, accountAction, transactionAction)
        case .ethplorer:
            let accountAction = EthplorerAPI2Action(type: .accounts, credentials: credentials)
            let transactionAction = EthplorerAPI2Action(type: .transactions(input: 50), credentials: credentials)
            refreshAction = (ethploreExchangeAPI, accountAction, transactionAction)
        case .bitfinex:
            let accountAction = BitfinexAPI2Action(type: .accounts, credentials: credentials)
            let transactionAction = BitfinexAPI2Action(type: .transactions(input: nil), credentials: credentials)
            refreshAction = (bitfinexExchangeAPI, accountAction, transactionAction)
        case .gdax, .coinbase:
            refreshAccountsForTransactions(with: institution, credentials: credentials)
            return
        case .blockchain:
            let accountAction = BTCAPI2Action.init(type: .accounts, credentials: credentials)
            refreshAction = (btcExchangeAPI, accountAction, nil)
        default:
            log.debug("Error - Can't trigger action for api with source \(institution.source.description)")
            return
        }
        
        guard let refreshAPIAction = refreshAction else {
            return
        }
        
        createRefreshOperations(with: refreshAPIAction, institution: institution, credentials: credentials)
    }
    
    func refreshAccessToken(for institution: Institution) {
        let credentialIdentifier = "\(institution.institutionId)"
        let credentials = keychainService.fetchCredentials(with: credentialIdentifier, source: institution.source, name: nil)
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
                self.refreshAccountsForTransactions(with: institution, credentials: refreshedCoinbaseCredentials)
            }
            
            if self.containsError(error, with: nil) {
                //TODO: change state
            }
        }
        
        guard let refreshTokenOperation = coinbaseRefreshTokenOperation else { return }
        autenticationQueue.addOperation(refreshTokenOperation)
    }
    
    func getCredentials(for institution: Institution) -> Credentials? {
        return keychainService.fetchCredentials(with: "\(institution.institutionId)", source: institution.source, name: institution.name)
    }
    
}

private extension ExchangeManager {
    
    func createRefreshOperations(with refreshAPIAction: ExchangeManagerRefreshAction , institution: Institution, credentials: Credentials) {
        let callBack: (Bool, Error?, Any?) -> Void = { (success, error, result) in
            let callbackResult = ExchangeManagerCallbackResult(success: success, error: error, result: result)
            self.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        guard let refreshAccountsOperation = refreshAPIAction.api.fetchData(for: refreshAPIAction.accountAction, completion: callBack) else {
            return
        }
        
        refreshQueue.addOperation(refreshAccountsOperation)
        
        guard let transactionAction = refreshAPIAction.transactionAction ,
            let refreshTransationOperation = refreshAPIAction.api.fetchData(for: transactionAction, completion: callBack) else {
            return
        }
        
        refreshQueue.addOperation(refreshTransationOperation)
    }
    
    func loginAction(from source: Source, with credentials: Credentials, callback: ExchangeOperationCompletionHandler? = nil) -> Operation?  {
        let callback: ExchangeOperationCompletionHandler = callback ?? { success, error, result in
            let callbackResult = ExchangeManagerCallbackResult(success: success, error: error, result: result)
            self.processLoginCallbackResult(callbackResult, source: source, credentials: credentials)
        }
        
        let loginAction: (api: AbstractApi, accountAction: APIAction)?
        
        switch source {
        case .poloniex:
            let exchangeAction = PoloniexApiAction(type: .accounts, credentials: credentials)
            loginAction = (poloniexExchangeAPI, exchangeAction)
        case .kraken:
            let exchangeAction = KrakenApiAction(type: .accounts, credentials: credentials)
            loginAction = (krakenExchangeAPI, exchangeAction)
        case .ethplorer:
            let exchangeAction = EthplorerAPI2Action(type: .accounts, credentials: credentials)
            loginAction = (ethploreExchangeAPI, exchangeAction)
        case .bitfinex:
            let exchangeAction = BitfinexAPI2Action(type: .accounts, credentials: credentials)
            loginAction = (bitfinexExchangeAPI, exchangeAction)
        case .gdax:
            let exchangeAction = GDAXAPI2Action(type: .accounts, credentials: credentials)
            loginAction = (gdaxExchangeAPI, exchangeAction)
        case .blockchain:
            let exchangeAction = BTCAPI2Action(type: .accounts, credentials: credentials)
            loginAction = (btcExchangeAPI, exchangeAction)
        default:
            return nil
        }
        
        guard let loginAPIAction = loginAction else {
            return nil
        }
        
        return loginAPIAction.api.fetchData(for: loginAPIAction.accountAction, completion: callback)
    }
    
}

//MARK: Reponse methods

private extension ExchangeManager {
    
    func processRefreshCallback(_ callbackResult: ExchangeManagerCallbackResult, institution: Institution, credentials: Credentials, triggerTransactions: Bool = false) {
        if let data = callbackResult.result,
            callbackResult.success {
            
            if let transactions = data as? [ExchangeTransaction] {
                repositoryService.createTransactions(for: institution.source, transactions: transactions, institution: institution)
                //TODO: change state
            }
            
            if let accounts = data as? [ExchangeAccount] {
                repositoryService.createAccounts(for: institution.source, accounts: accounts, institution: institution)
                //TODO: change state
                
                if triggerTransactions {
                    refreshTransactionsFromAccounts(with: institution, credentials: credentials)
                }
            }
            
            if institution.passwordInvalid {
                keychainService.save(source: institution.source, identifier: "\(institution.institutionId)", credentials: credentials)
                institution.passwordInvalid = false
                institution.replace()
            }
            
            return
        }
        
        if containsError(callbackResult.error, with: institution) {
            //TODO: remove the operation for insitution if there is one pending(account operation, transaction operation)
        }
    }
    
    func processLoginCallbackResult(_ callbackResult: ExchangeManagerCallbackResult, source: Source, credentials: Credentials, institution: Institution? = nil) {
        if let data = callbackResult.result,
            callbackResult.success {
            
            guard let institution = institution ?? repositoryService.createInstitution(for: source, name: credentials.name) else {
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
    
    
    func refreshAccountsForTransactions(with institution: Institution, credentials: Credentials) {
        let refreshCallBack: (Bool, Error?, Any?) -> Void = { (success, error, result) in
            let callbackResult = ExchangeManagerCallbackResult(success: success, error: error, result: result)
            self.processRefreshCallback(callbackResult, institution: institution, credentials: credentials, triggerTransactions: true)
        }
        
        guard let loginOperation = loginAction(from: institution.source, with: credentials, callback: refreshCallBack) else {
            return
        }
        
        autenticationQueue.addOperation(loginOperation)
    }
    
    func refreshTransactionsFromAccounts(with institution: Institution, credentials: Credentials) {
        let callBack: (Bool, Error?, Any?) -> Void = { (success, error, result) in
            let callbackResult = ExchangeManagerCallbackResult(success: success, error: error, result: result)
            self.processRefreshCallback(callbackResult, institution: institution, credentials: credentials)
        }
        
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        
        guard !accounts.isEmpty else {
            log.debug("Warning - Can't refresh coinbase institution with \(institution.institutionId) id")
            return
        }
        
        for account in accounts {
            let transactionOperation: Operation?

            switch institution.source {
            case .coinbase:
                let transactionAction = CoinbaseAPI2Action(type: .transactions(input: account.sourceAccountId), credentials: credentials)
                transactionOperation = coinbaseExchangeAPI.fetchData(for: transactionAction, completion: callBack)
            case .gdax:
                let transactionDict: [String: Any] = [
                    GDAXAPI2Action.TransactionInputDataType.accountId.rawValue: account.sourceAccountId,
                    GDAXAPI2Action.TransactionInputDataType.currencyCode.rawValue: account.currency
                ]
                let transactionAction = GDAXAPI2Action(type: .transactions(input: transactionDict), credentials: credentials)
                transactionOperation = gdaxExchangeAPI.fetchData(for: transactionAction, completion: callBack)
            default:
                return
            }

            
            guard let operation = transactionOperation else {
                print("Can't create refresh operation for \(institution.source.description) with institution \(institution.institutionId) id")
                continue
            }
            
            refreshQueue.addOperation(operation)
        }
    }
    
}

// MARK: Coinbase helper methods

private extension ExchangeManager {
    
    func launchCoinbaseAutentication(with data: Any) {
        let operation = coinbaseExchangeAPI.startAutentication(with: data) { success, error, result in
            if let coinbaseOAUTHCredentials = result as? OAUTHCredentials,
                let coinbaseInstitution = self.repositoryService.createInstitution(for: .coinbase, name: ""),
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
            let callbackResult = ExchangeManagerCallbackResult(success: success, error: error, result: result)
            self?.processLoginCallbackResult(callbackResult, source: institution.source, credentials: credentials, institution: institution)
        }
        
        if let accountOperation = coinbaseAccountsOperation {
            autenticationQueue.addOperation(accountOperation)
        }

    }
    
}
