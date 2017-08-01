//
//  Syncer.swift
//  Bal
//
//  Created by Benjamin Baron on 2/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

typealias SuccessErrorsBlock = (_ success: Bool, _ errors: [Error]?) -> Void
typealias CanceledBlock = () -> (Bool)

class Syncer {
    fileprivate(set) var syncing = false
    fileprivate(set) var canceled = false
    
    fileprivate var completionBlock: SuccessErrorsBlock?
    
    fileprivate var canceledBlock: CanceledBlock {
        return {
            return self.canceled
        }
    }
    
    private let gdaxAPIClient = GDAXAPIClient(server: .sandbox)
    
    // MARK: -
    
    func cancel() {
        canceled = true
    }
    
    func sync(beginDate: Date, completion: SuccessErrorsBlock?) {
        guard !syncing else {
            return
        }
        
        self.syncing = true
        self.completionBlock = completion
        
        log.debug("Syncing started")
        NotificationCenter.postOnMainThread(name: Notifications.SyncStarted)
        
        if Institution.institutionsCount > 0 {
            let success = true
            let errors = [Error]()
            let institutions = Institution.allInstitutions(sorted: true)
            if self.canceled {
                self.cancelSync(errors: errors)
            } else if institutions.count == 0 {
                self.completeSync(success: success, errors: errors)
            } else {
                // Recursively sync the institutions (reversed because we use popLast)
                self.syncInstitutions(institutions.reversed(), beginDate: beginDate, success: success, errors: errors)
            }
        } else {
            self.completeSync(success: true, errors: [Error]())
        }
    }
    
    // Recursively iterate through the institutions, syncing one at a time
    fileprivate func syncInstitutions(_ institutions: [Institution], beginDate: Date, success: Bool, errors: [Error]) {
        var syncingInstitutions = institutions
        
        if !canceled, let institution = syncingInstitutions.popLast() {
            if institution.passwordInvalid {
                // Institution needs a PATCH, so skip
                log.error("Tried to sync institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but the password was invalid")
                syncInstitutions(syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
            } else if institution.accessToken == nil {
                // No access token somehow, so move on to the next one
                log.severe("Tried to sync institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but did not find an access token")
                syncInstitutions(syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
            } else if institution.sourceId == .coinbase && institution.isTokenExpired {
                if institution.refreshToken == nil {
                    // No refresh token somehow, so move on to the next one
                    log.severe("Tried to refresh access token for institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name) but did not find a refresh token")
                    syncInstitutions(syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
                } else {
                    // Refresh the token
                    CoinbaseApi.refreshAccessToken(institution: institution) { success, error in
                        if success {
                            self.syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
                        } else {
                            log.error("Failed to refresh token for institution \(institution.institutionId) (\(institution.sourceInstitutionId)): \(institution.name)")
                            self.syncInstitutions(syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
                        }
                    }
                }
            } else if institution.accessToken != nil {
                // Valid institution, so sync it
                syncAccountsAndTransactions(institution: institution, remainingInstitutions: syncingInstitutions, beginDate: beginDate, success: success, errors: errors)
            }
        } else {
            // No more institutions
            completeSync(success: success, errors: errors)
        }
    }

    fileprivate func syncAccountsAndTransactions(institution: Institution, remainingInstitutions: [Institution], beginDate: Date, success: Bool, errors: [Error]) {
        var syncingSuccess = success
        var syncingErrors = errors
        
        let userInfo = Notifications.userInfoForInstitution(institution)
        NotificationCenter.postOnMainThread(name: Notifications.SyncingInstitution, object: nil, userInfo: userInfo)
        
        log.debug("Pulling accounts and transactions for \(institution)")
        
        switch institution.sourceId
        {
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
                
                if self.canceled {
                    self.cancelSync(errors: syncingErrors)
                    return
                }
                
                self.syncInstitutions(remainingInstitutions, beginDate: beginDate, success: syncingSuccess, errors: syncingErrors)
            }
        case .gdax:
            guard let accessToken = institution.accessToken,
                  let credentials = try? GDAXAPIClient.Credentials(identifier: accessToken) else
            {
                return
            }
            
            self.gdaxAPIClient.credentials = credentials
            self.gdaxAPIClient.fetchAccounts({ (accounts, error) in
                guard let unwrappedAccounts = accounts else
                {
                    return
                }
                
                for account in unwrappedAccounts
                {
                    var decimals = 2
                    if let currency = Currency(rawValue: account.currencyCode)
                    {
                        decimals = currency.decimals
                    }
                    
                    // Calculate the integer value of the balance based on the decimals
                    var balance = Decimal(account.balance)
                    balance = balance * Decimal(pow(10.0, Double(decimals)))
                    let currentBalance = (balance as NSDecimalNumber).intValue

                    balance = Decimal(account.availableBalance)
                    balance = balance * Decimal(pow(10.0, Double(decimals)))
                    let availableBalance = (balance as NSDecimalNumber).intValue
                    
                    // Initialize an Account object to insert the record
                    _ = Account(institutionId: institution.institutionId, sourceId: institution.sourceId, sourceAccountId: account.identifier, sourceInstitutionId: "", accountTypeId: AccountType.depository, accountSubTypeId: nil, name: account.currencyCode, currency: account.currencyCode, decimals: decimals, currentBalance: currentBalance, availableBalance: availableBalance, number: nil, altCurrency: nil, altDecimals: nil, altCurrentBalance: nil, altAvailableBalance: nil)
                }
            })
        default:()
        }
    }
    
    fileprivate func cancelSync(errors: [Error]) {
        completeSync(success: false, errors: errors)
    }
    
    fileprivate func completeSync(success: Bool, errors: [Error]) {
        DispatchQueue.main.async {
            // Call the completion block
            self.completionBlock?(success, errors)
            self.completionBlock = nil
            
            // Done syncing
            self.syncing = false
            
            log.debug("Syncing completed")
        }
    }
}
