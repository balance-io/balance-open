//
//  Syncer.swift
//  Bal
//
//  Created by Benjamin Baron on 2/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class Syncer {
    fileprivate let gdaxApiClient = GDAXAPIClient(server: .production)
    fileprivate let bitfinexApiClient = BitfinexAPIClient()
    fileprivate let krakenApiClient = KrakenAPIClient()
    
    fileprivate(set) var syncing = false
    fileprivate(set) var canceled = false
    
    fileprivate var completionBlock: SuccessErrorsHandler?
    
    func cancel() {
        canceled = true
    }
    
    func sync(startDate: Date, pruneTransactions: Bool = false, skip: [Source] = [], completion: SuccessErrorsHandler?) {
        guard !syncing else {
            return
        }
        
        self.syncing = true
        self.completionBlock = completion
        
        log.debug("Syncing started")
        NotificationCenter.postOnMainThread(name: Notifications.SyncStarted)
        
        if InstitutionRepository.si.institutionsCount > 0 {
            // Grab the institutions again in case we've added one while syncing categories or we've been canceled
            // and sort them as they're displayed in the UI
            let institutions = InstitutionRepository.si.allInstitutions(sorted: true).filter { institution -> Bool in
                return !skip.contains(institution.source)
            }
            
            let success = true
            let errors = [Error]()
            if self.canceled {
                self.cancelSync(errors: errors)
            } else if institutions.count == 0 {
                self.completeSync(success: success, errors: errors)
            } else {
                // Recursively sync the institutions (reversed because we use popLast)
                self.syncInstitutions(institutions.reversed(), startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
            }
        } else {
            self.completeSync(success: true, errors: [Error]())
        }
    }

    // Recursively iterate through the institutions, syncing one at a time
    fileprivate func syncInstitutions(_ institutions: [Institution], startDate: Date, success: Bool, errors: [Error], pruneTransactions: Bool = false) {
        var syncingInstitutions = institutions
        
        if !canceled, let institution = syncingInstitutions.popLast() {
            log.debug("institutions: \(institutions) syncingInstitutions: \(syncingInstitutions)")
            if institution.passwordInvalid {
                // Institution needs a PATCH, so skip -> we should delete and prompt to log in again
                log.error("Tried to sync institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but the password was invalid")
                syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
            } else if institution.accessToken == nil && institution.source == .coinbase {
                // No access token somehow, so move on to the next one
                log.severe("Tried to sync institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but did not find an access token")
                syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
            } else if institution.source == .coinbase && institution.isTokenExpired {
                if institution.refreshToken == nil {
                    // No refresh token somehow, so move on to the next one
                    log.severe("Tried to refresh access token for institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but did not find a refresh token")
                    institution.passwordInvalid = true
                    institution.replace()
                    syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                } else {
                    // Refresh the token
                    CoinbaseApi.refreshAccessToken(institution: institution) { success, error in
                        if success {
                            self.syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                        } else {
                            log.error("Failed to refresh token for institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) error: \(String(describing: error?.localizedDescription)) error code:\(String(describing: error?.code))")
                            self.syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                        }
                    }
                }
            } else if institution.source == .bittrex {
                if institution.apiKey == nil || institution.secret == nil {
                    institution.passwordInvalid = true
                    institution.replace()
                    syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                } else {
                    syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                }
            } else if institution.source == .poloniex {
                if let apiKey = institution.apiKey, let secret = institution.secret {
                    syncPoloniexAccountsAndTransactions(secret: secret, key: apiKey, institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors)
                } else {
                    //logout and ask for resync
                    log.error("Failed get api and key for \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name)")
                    self.syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                }
            } else if institution.source == .ethplorer {
                //ethplorer
                if let address = institution.address {
                    syncWallet(address: address, institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors)
                } else {
                    log.error("Failed to get the stored Address for the wallet")
                    self.syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)                }
            } else if institution.accessToken != nil  {
                // Valid institution, so sync it
                syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
            }
        } else {
            // No more institutions
            completeSync(success: success, errors: errors)
        }
    }
    
    fileprivate func syncAccountsAndTransactions(institution: Institution, remainingInstitutions: [Institution], startDate: Date, success: Bool, errors: [Error], pruneTransactions: Bool = false) {
        var syncingSuccess = success
        var syncingErrors = errors
        
        let userInfo = Notifications.userInfoForInstitution(institution)
        NotificationCenter.postOnMainThread(name: Notifications.SyncingInstitution, object: nil, userInfo: userInfo)
        
        log.debug("Pulling accounts and transactions for \(institution)")
        
        // Perform next sync handler
        let performNextSyncHandler = { (_ remainingInstitutions: [Institution], _ startDate: Date, _ syncingSuccess: Bool, _ syncingErrors: [Error]) -> Void in
            if self.canceled {
                self.cancelSync(errors: syncingErrors)
                return
            }
            
            self.syncInstitutions(remainingInstitutions, startDate: startDate, success: syncingSuccess, errors: syncingErrors, pruneTransactions: pruneTransactions)
        }
        
        // Perform sync
        switch institution.source {
        case .coinbase:
            CoinbaseApi.updateAccounts(institution: institution) { success, error in
                if !success {
                    syncingSuccess = false
                    if let error = error {
                        syncingErrors.append(error)
                        log.error("Error pulling accounts for \(institution): \(error)")
                    }
                    log.debug("Finished pulling accounts for \(institution)")
                }
                
                let dispatchGroup = DispatchGroup()
                for account in AccountRepository.si.accounts(institutionId: institution.institutionId) {
                    dispatchGroup.enter()
                    CoinbaseApi.fetchTransactions(accountID: account.sourceAccountId, institution: institution, completionHandler: { (transactions, error) in
                        if let unwrappedTransactions = transactions {
                            for transaction in unwrappedTransactions
                            {
                                let amount = paddedInteger(for: transaction.amount, currencyCode: transaction.currencyCode)
                                
                                TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: transaction.identifier, sourceAccountId: account.sourceAccountId, name: transaction.identifier, currency: transaction.currencyCode, amount: amount, date: transaction.createdAt, categoryID: nil, institution: institution)
                            }
                        }
                        
                        dispatchGroup.leave()
                    })
                }
                
                dispatchGroup.notify(queue: .main) {
                    performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                }
            }
        case .gdax:
            guard let accessToken = institution.accessToken else {
                institution.passwordInvalid = true
                institution.replace()
                syncingSuccess = false
                syncingErrors.append(BalanceError.authenticationError)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
            
            // Load credentials
            do {
                if verify(accessToken: accessToken) == nil {
                    let accessToken = String(institution.institutionId)
                    institution.accessToken = accessToken
                }
                let credentials = try GDAXAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from GDAX
                self.gdaxApiClient.credentials = credentials
                try self.gdaxApiClient.fetchAccounts { accounts, error in
                    guard let unwrappedAccounts = accounts else {
                        if let unwrappedError = error {
                            syncingErrors.append(unwrappedError)
                        }
                        
                        syncingSuccess = false
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        return
                    }
                    
                    for account in unwrappedAccounts {
                        let currentBalance = paddedInteger(for: account.balance, currencyCode: account.currencyCode)
                        let availableBalance = paddedInteger(for: account.availableBalance, currencyCode: account.currencyCode)
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.identifier, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                }
                let dispatchGroup = DispatchGroup()
                for account in AccountRepository.si.accounts(institutionId: institution.institutionId) {
                    dispatchGroup.enter()
                        try self.gdaxApiClient.fetchTranactions(accountId: String(account.sourceAccountId), currencyCode: account.currency, { (transactions, error) in
                            if let unwrappedTransactions = transactions {
                                for transaction in unwrappedTransactions {
                                    let amount = paddedInteger(for: transaction.amount, currencyCode: transaction.currencyCode)
                                    
                                    TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: transaction.id, sourceAccountId: account.sourceAccountId, name: account.currency, currency: transaction.currencyCode, amount: amount, date: transaction.createdAt, categoryID: nil, institution: institution)
                                }
                            }
                            dispatchGroup.leave()
                        })
                }
                dispatchGroup.notify(queue: .main) {
                    performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                }
            } catch {
                if let credentialsError = error as? APICredentialsComponents.Error {
                    switch credentialsError {
                    case .dataNotReachable:
                        institution.passwordInvalid = true
                        institution.replace()
                    default:
                        log.debug("Unaccounted for error: \(error)")
                    }
                }
                syncingSuccess = false
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
        case .bitfinex:
            guard let accessToken = institution.accessToken else {
                institution.passwordInvalid = true
                institution.replace()
                syncingSuccess = false
                syncingErrors.append(BalanceError.authenticationError)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
            
            // Load credentials
            do {
                if verify(accessToken: accessToken) == nil {
                    let accessToken = String(institution.institutionId)
                    institution.accessToken = accessToken
                }
                let credentials = try BitfinexAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from Bitfinex
                self.bitfinexApiClient.credentials = credentials
                try self.bitfinexApiClient.fetchWallets { wallets, error in
                    guard let unwrappedWallets = wallets else {
                        if let unwrappedError = error {
                            syncingErrors.append(unwrappedError)
                        }
                        syncingSuccess = false
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        return
                    }
                    
                    for wallet in unwrappedWallets {
                        let currentBalance = paddedInteger(for: wallet.balance, currencyCode: wallet.currencyCode)
                        let availableBalance = currentBalance
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: wallet.currencyCode, sourceInstitutionId: institution.sourceInstitutionId, accountTypeId: .exchange, accountSubTypeId: nil, name: wallet.currencyCode, currency: wallet.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                    
                    do {
                        // Sync transactions
                        try self.bitfinexApiClient.fetchTransactions { transactions, error in
                            guard let unwrappedTransactions = transactions else {
                                if let unwrappedError = error {
                                    syncingErrors.append(unwrappedError)
                                }
                                syncingSuccess = false
                                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                                return
                            }
                            
                            for transaction in unwrappedTransactions {
                                let amount = paddedInteger(for: transaction.amount, currencyCode: transaction.currencyCode)
                                let identifier = "\(transaction.address)\(transaction.amount)\(transaction.movementTimestamp)"
                                
                                TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: identifier, sourceAccountId: transaction.currencyCode, name: identifier, currency: transaction.currencyCode, amount: amount, date: transaction.createdAt, categoryID: nil, institution: institution)
                            }
                            
                            performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        }
                    } catch {
                        syncingSuccess = false
                        syncingErrors.append(error)
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                    }
                }
            } catch {
                if let credentialsError = error as? APICredentialsComponents.Error {
                    switch credentialsError {
                    case .dataNotReachable:
                        institution.passwordInvalid = true
                        institution.replace()
                    default:
                        log.debug("Unaccounted for error: \(error)")
                    }
                }
                
                syncingSuccess = false
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
        case .kraken:
            guard let accessToken = institution.accessToken else {
                institution.passwordInvalid = true
                institution.replace()
                syncingSuccess = false
                syncingErrors.append(BalanceError.authenticationError)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
            
            // Load credentials
            do {
                if verify(accessToken: accessToken) == nil {
                    let accessToken = String(institution.institutionId)
                    institution.accessToken = accessToken
                }
                let credentials = try KrakenAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from Kraken
                self.krakenApiClient.credentials = credentials
                try self.krakenApiClient.fetchAccounts { accounts, error in
                    guard let unwrappedAccounts = accounts else {
                        if let unwrappedError = error {
                            syncingErrors.append(unwrappedError)
                        }
                        
                        syncingSuccess = false
                        return
                    }
                    
                    for account in unwrappedAccounts {
                        let currentBalance = paddedInteger(for: account.balance, currencyCode: account.currencyCode)
                        let availableBalance = currentBalance
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.currencyCode, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                    
                    do {
                        try self.krakenApiClient.fetchTransactions { transactions, error in
                            guard let unwrappedTransactions = transactions else {
                                if let unwrappedError = error {
                                    syncingErrors.append(unwrappedError)
                                }
                                
                                syncingSuccess = false
                                return
                            }
                            
                            for transaction in unwrappedTransactions {
                                let amount = paddedInteger(for: transaction.amount, currencyCode: transaction.asset.code)
                                let identifier = "\(transaction.ledgerId)\(transaction.amount)\(transaction.time)"
                                
                                TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: identifier, sourceAccountId: transaction.asset.code, name: identifier, currency: transaction.asset.code, amount: amount, date: transaction.time, categoryID: nil, institution: institution)
                            }
                            
                            performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        }
                    } catch {
                        syncingSuccess = false
                        syncingErrors.append(error)
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                    }
                }
            } catch {
                if let credentialsError = error as? APICredentialsComponents.Error {
                    switch credentialsError {
                    case .dataNotReachable:
                        institution.passwordInvalid = true
                        institution.replace()
                    default:
                        log.debug("Unaccounted for error: \(error)")
                    }
                }
                
                syncingSuccess = false
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
        case .bittrex:
            guard let apiKey = institution.apiKey, let secretKey = institution.secret else {
                institution.passwordInvalid = true
                institution.replace()
                syncingSuccess = false
                syncingErrors.append(BalanceError.authenticationError)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
            
            // Fixes the special case in Bittrex where they incorrectly use the BCC ticker symbol
            // for BCH (Bitcoin Cash). BCC is already the symbol of Bitconnect so we can't just make
            // them equivalent in the Currency enum and everyone else uses BCH, so we need to save
            // BCC from Bittrex as BCH for it to work correctly.
            func bittrexFixCurrencyCode(_ currencyCode: String) -> String {
                if currencyCode == "BCC" {
                    return "BCH"
                }
                return currencyCode
            }
            
            func processBalances(result: ExchangeAPIResult) {
                guard let balances = result.object as? [BITTREXBalance] else {
                    syncingSuccess = false
                    syncingErrors.append(BalanceError.unexpectedData)
                    return
                }
                
                for balance in balances {
                    let currencyCode = bittrexFixCurrencyCode(balance.currency)
                    let currentBalance = paddedInteger(for: balance.balance, currencyCode: currencyCode)
                    let availableBalance = currentBalance
                    
                    // Initialize an Account object to insert the record
                    AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: currencyCode, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: currencyCode, currency: currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                }
            }
            
            func processDeposits(result: ExchangeAPIResult) {
                guard let deposits = result.object as? [BITTREXDeposit] else {
                    syncingSuccess = false
                    syncingErrors.append(BalanceError.unexpectedData)
                    return
                }
                
                for deposit in deposits {
                    guard let date = deposit.date else {
                        log.error("Failed to format date for Bittrex deposit \(deposit.id) with date string \(deposit.lastUpdated)")
                        continue
                    }
                    
                    let currencyCode = bittrexFixCurrencyCode(deposit.currency)
                    let amount = paddedInteger(for: deposit.amount, currencyCode: currencyCode)
                    
                    // NOTE: Maybe we shoul be using txId here instead of id?
                    TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: String(deposit.id), sourceAccountId: currencyCode, name: String(deposit.id), currency: currencyCode, amount: amount, date: date, categoryID: nil, institution: institution)
                }
            }
            
            func processWithdrawals(result: ExchangeAPIResult) {
                guard let withdrawals = result.object as? [BITTREXWithdrawal] else {
                    syncingSuccess = false
                    syncingErrors.append(BalanceError.unexpectedData)
                    return
                }
                
                for withdrawal in withdrawals {
                    guard let date = withdrawal.date else {
                        log.error("Failed to format date for Bittrex withdrawal \(withdrawal.paymentUuid) with date string \(withdrawal.opened)")
                        continue
                    }
                    
                    let currencyCode = bittrexFixCurrencyCode(withdrawal.currency)
                    let amount = paddedInteger(for: withdrawal.amount, currencyCode: currencyCode)
                    
                    TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: withdrawal.paymentUuid, sourceAccountId: currencyCode, name: withdrawal.paymentUuid, currency: currencyCode, amount: amount, date: date, categoryID: nil, institution: institution)
                }
            }
            
            BITTREXApi().performAction(for: .getBalances, apiKey: apiKey, secretKey: secretKey) { result in
                processBalances(result: result)
                
                BITTREXApi().performAction(for: .getAllDepositHistory, apiKey: apiKey, secretKey: secretKey) { depositResult in
                    processDeposits(result: depositResult)
                    
                    BITTREXApi().performAction(for: .getAllWithdrawalHistory, apiKey: apiKey, secretKey: secretKey) { withdrawalResult in
                        processWithdrawals(result: withdrawalResult)
                        
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                    }
                }
            }
        default:
            break
        }
    }
    
    fileprivate func syncPoloniexAccountsAndTransactions(secret: String, key: String, institution: Institution, remainingInstitutions: [Institution], startDate: Date, success: Bool, errors: [Error]) {
        var syncingSuccess = success
        var syncingErrors = errors
        
        let userInfo = Notifications.userInfoForInstitution(institution)
        NotificationCenter.postOnMainThread(name: Notifications.SyncingInstitution, object: nil, userInfo: userInfo)
        log.debug("Pulling accounts and transactions for \(institution)")
        
        //sync Poloniex
        let poloniexApi = PoloniexApi(secret: secret, key: key)
        poloniexApi.fetchBalances(institution: institution) { success, error in
            if !success {
                syncingSuccess = false
                if let error = error {
                    syncingErrors.append(error)
                    log.error("Error pulling accounts for \(institution): \(error)")
                }
            }
            
            if self.canceled {
                self.cancelSync(errors: syncingErrors)
                return
            }
            
            poloniexApi.fetchTransactions(institution: institution, completion: { (success, error) in
                
                if let error = error {
                    syncingSuccess = false
                    syncingErrors.append(error)
                    log.error("Error pulling transactions for \(institution): \(error)")
                }
                
                self.syncInstitutions(remainingInstitutions, startDate: startDate, success: syncingSuccess, errors: syncingErrors)
            })
        }
    }
    
    fileprivate func syncWallet(address: String, institution: Institution, remainingInstitutions: [Institution], startDate: Date, success: Bool, errors:[Error]) {
        var syncingSuccess = success
        var syncingErrors = errors
        
        let userInfo = Notifications.userInfoForInstitution(institution)
        NotificationCenter.postOnMainThread(name: Notifications.SyncingInstitution, object: nil, userInfo: userInfo)
        log.debug("Pulling accounts and transactions for \(institution)")
        
        //sync Ethplore
        let ethploreApi = EthplorerApi(name: "", address: address)
        ethploreApi.fetchAddressInfo(institution: institution, completion: { (success, error) in
            if !success {
                syncingSuccess = false
                if let error = error {
                    syncingErrors.append(error)
                    log.error("Error pulling accounts for \(institution): \(error)")
                }
            }
            
            if self.canceled {
                self.cancelSync(errors: syncingErrors)
                return
            }
            self.syncInstitutions(remainingInstitutions, startDate: startDate, success: syncingSuccess, errors: syncingErrors)
        })
    }
    
    fileprivate func cancelSync(errors: [Error]) {
        completeSync(success: false, errors: errors)
    }
    
    fileprivate func completeSync(success: Bool, errors: [Error]) {
        async {
            // Call the completion block
            self.completionBlock?(success, errors)
            self.completionBlock = nil
            
            // Done syncing
            self.syncing = false
            
            log.debug("Syncing completed")
        }
    }
  
    // MARK: Helpers
    
    // If not nil then means is not validated and the token needs to be replaced
    func verify(accessToken: String) -> String? {
        if accessToken == "main" {
            return nil
        } else { return accessToken }
    }
}

class MockSyncer: Syncer {
    override func sync(startDate: Date, pruneTransactions: Bool, skip: [Source] = [], completion: SuccessErrorsHandler?) {
        guard !syncing else {
            return
        }
        
        syncing = true
        NotificationCenter.postOnMainThread(name: Notifications.SyncStarted)
        
        DispatchQueue.userInteractive.async(after: 3.0) {
            self.syncing = false
            async { completion?(true, nil) }
        }
    }
}
