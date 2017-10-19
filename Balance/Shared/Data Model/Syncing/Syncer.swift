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
    
    func sync(startDate: Date, pruneTransactions: Bool = false, completion: SuccessErrorsHandler?) {
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
            let institutions = InstitutionRepository.si.allInstitutions(sorted: true)
            
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
                // Institution needs a PATCH, so skip
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
                    syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                } else {
                    // Refresh the token
                    CoinbaseApi.refreshAccessToken(institution: institution) { success, error in
                        if success {
                            self.syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                        } else {
                            log.error("Failed to refresh token for institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name)")
                            NotificationCenter.postOnMainThread(name: Notifications.SyncError, object: institution,  userInfo: nil)
                            self.syncInstitutions(syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
                        }
                    }
                }
            } else if institution.accessToken != nil  {
                // Valid institution, so sync it
                syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, startDate: startDate, success: success, errors: errors, pruneTransactions: pruneTransactions)
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
                                let amount = self.paddedInteger(for: transaction.amount, currencyCode: transaction.currencyCode)
                                
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
                syncingSuccess = false
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
            
            // Load credentials
            do {
                let credentials = try GDAXAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from GDAX
                self.gdaxApiClient.credentials = credentials
                try! self.gdaxApiClient.fetchAccounts { accounts, error in
                    guard let unwrappedAccounts = accounts else
                    {
                        if let unwrappedError = error
                        {
                            syncingErrors.append(unwrappedError)
                        }
                        
                        syncingSuccess = false
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        return
                    }
                    
                    for account in unwrappedAccounts {
                        let currentBalance = self.paddedInteger(for: account.balance, currencyCode: account.currencyCode)
                        let availableBalance = self.paddedInteger(for: account.availableBalance, currencyCode: account.currencyCode)
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.identifier, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                    
                    performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                }
            } catch {
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                return
            }
        case .bitfinex:
            guard let accessToken = institution.accessToken else {
                syncingSuccess = false
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                
                return
            }
            
            // Load credentials
            do {
                let credentials = try BitfinexAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from Bitfinex
                self.bitfinexApiClient.credentials = credentials
                try! self.bitfinexApiClient.fetchWallets { wallets, error in
                    guard let unwrappedWallets = wallets else {
                        if let unwrappedError = error {
                            syncingErrors.append(unwrappedError)
                        }
                        
                        syncingSuccess = false
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        
                        return
                    }
                    
                    for wallet in unwrappedWallets {
                        let currentBalance = self.paddedInteger(for: wallet.balance, currencyCode: wallet.currencyCode)
                        let availableBalance = currentBalance
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: wallet.currencyCode, sourceInstitutionId: institution.sourceInstitutionId, accountTypeId: .exchange, accountSubTypeId: nil, name: wallet.currencyCode, currency: wallet.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                    
                    // Sync transactions
                    try! self.bitfinexApiClient.fetchTransactions({ (transactions, error) in
                        if let unwrappedTransactions = transactions
                        {
                            for transaction in unwrappedTransactions
                            {
                                let amount = self.paddedInteger(for: transaction.amount, currencyCode: transaction.currencyCode)
                                let identifier = "\(transaction.address)\(transaction.amount)\(transaction.movementTimestamp)"

                                TransactionRepository.si.transaction(source: institution.source, sourceTransactionId: identifier, sourceAccountId: transaction.currencyCode, name: identifier, currency: transaction.currencyCode, amount: amount, date: transaction.createdAt, categoryID: nil, institution: institution)
                            }
                        }
                        
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                    })
                }
            } catch {
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                
                return
            }
        case .kraken:
            guard let accessToken = institution.accessToken else {
                syncingSuccess = false
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                
                return
            }
            
            // Load credentials
            do {
                let credentials = try KrakenAPIClient.Credentials(identifier: accessToken)
                
                // Fetch data from Bitfinex
                self.krakenApiClient.credentials = credentials
                try! self.krakenApiClient.fetchAccounts { accounts, error in
                    guard let unwrappedAccounts = accounts else {
                        if let unwrappedError = error {
                            syncingErrors.append(unwrappedError)
                        }
                        
                        syncingSuccess = false
                        performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                        
                        return
                    }
                    
                    for account in unwrappedAccounts {
                        let currentBalance = self.paddedInteger(for: account.balance, currencyCode: account.currencyCode)
                        let availableBalance = currentBalance
                        
                        // Initialize an Account object to insert the record
                        AccountRepository.si.account(institutionId: institution.institutionId, source: institution.source, sourceAccountId: account.currencyCode, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                    }
                    
                    performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                }
            } catch {
                syncingErrors.append(error)
                performNextSyncHandler(remainingInstitutions, startDate, syncingSuccess, syncingErrors)
                
                return
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
                log.debug("Finished pulling accounts for \(institution)")
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
                log.debug("Finished pulling accounts for \(institution)")
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
    
    private func paddedInteger(for amount: Double, currencyCode: String) -> Int {
        let decimals = Currency.rawValue(currencyCode).decimals
        
        var amountDecimal = Decimal(amount)
        amountDecimal = amountDecimal * Decimal(pow(10.0, Double(decimals)))
        
        return (amountDecimal as NSDecimalNumber).intValue
    }
}

class MockSyncer: Syncer {
    override func sync(startDate: Date, pruneTransactions: Bool, completion: SuccessErrorsHandler?) {
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
