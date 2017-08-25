//
//  PlaidApi.swift
//  Bal
//
//  Created by Benjamin Baron on 2/1/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

// Used by the sync process to check if it's been canceled before writing data to the database
typealias CanceledBlock = () -> (Bool)

fileprivate enum ConnectionIssueType: Int {
    case newConnection    = 0
    case patchConnection  = 1
    case pullBalance      = 2
    case pullTransactions = 3
}

fileprivate enum PlaidEnvironment {
    case sandbox
    case production
    
    var baseUrl: String {
        switch self {
        case .sandbox:
            return "https://sandbox.plaid.com"
        case .production:
            return "https://production.plaid.com"
        }
    }
}

struct PlaidApi {
    
    fileprivate static let publicKey = "e60169526514437b2aeaa2e4ae0a77"
    fileprivate static let environment = PlaidEnvironment.production
    fileprivate static let baseUrl = environment.baseUrl
    fileprivate static let connectionTimeout = 240.0
    
    fileprivate static let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
    
    fileprivate static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-M-d"
        return dateFormatter
    }()
    
    fileprivate static func formatDate(_ dateString: String) -> Date {
        let date = dateFormatter.date(from: dateString)
        
        // TODO: Decide what to do if a date formatting fails...
        assert(date != nil, "Date should always be in this format")
        return date ?? Date()
    }
    
    static func linkInitializationUrl(sourceInstitutionId: String) -> URL {
        let config = [
            "key": "e60169526514437b2aeaa2e4ae0a77",
            //"env": "production",
            "env": "sandbox",
            "product": "transactions",
            "selectAccount": "false",
            "clientName": "Balance",
            "isMobile": "true",
            "isWebview": "true",
            "apiVersion": "v2",
            "institution": sourceInstitutionId
        ]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cdn.plaid.com"
        components.path = "/link/v2/stable/link.html"
        components.queryItems = config.map { (NSURLQueryItem(name: $0, value: $1) as URLQueryItem) }
        return components.url!
    }
    
    //
    // MARK: - API Calls -
    //
    
    static func pullCategories(completion: SuccessErrorHandler? = nil) {
        let url = URL(string: "\(baseUrl)/categories")!
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            // Make sure there's data
            guard let data = maybeData, maybeError == nil else {
                log.error("Failed to pull categories, maybeData == nil: \(maybeData == nil) error: \(maybeError!)")
                async { completion?(false, maybeError!) }
                return
            }
            
            // Try to parse the JSON
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]] {
                    // Map the categories
                    var managedCategories = [PlaidCategory]()
                    for result in jsonResult {
                        do {
                            let category = try PlaidCategory(category: result)
                            managedCategories.append(category)
                        } catch {
                            log.error("Error parsing plaid category: \(error)")
                        }
                    }
                    
                    // Process the categories into our database
                    processCategories(managedCategories)
                } else {
                    throw "Failed to cast to [[String: AnyObject]]"
                }
                
                async { completion?(true, maybeError) }
            } catch {
                log.error("Failed to pull categories, json decoding failed with error: \(error)")
                async { completion?(false, nil) }
            }
        }
        
        task.resume()
    }
    
//    fileprivate static func handlePullError(institution: Institution, error: Error) {
//        if let plaidError = PlaidError(rawValue: error.code) {
//            if plaidError.requiresPatch {
//                log.debug("Institution password or mfa changed, requires a patch call, error code: \(error.code)")
//                institution.passwordInvalid = true
//                institution.updateModel()
//            } else if plaidError == .itemNotFound, let accessToken = institution.accessToken {
//                log.debug("Received an itemNotFound error which means somehow this token was deleted, so removing the institution")
//                subscriptionManager.deleteAccessToken(accessToken: accessToken) { success, _, _, _, _ in
//                    if success || accessToken.hasPrefix("test_") {
//                        institution.remove()
//                    }
//                }
//            }
//        }
//    }
    
    static func pullAccountsAndTransactions(institution: Institution, startDate: Date?, pruneTransactions: Bool = false, canceled: CanceledBlock? = nil, completion: SuccessErrorHandler? = nil) {
        guard let accessToken = institution.accessToken else {
            log.error("Missing access token for \(institution)")
            async { completion?(false, "Missing access token") }
            return
        }
        
        var mappedAccounts = [PlaidAccount]()
        var mappedTransactions = [PlaidTransaction]()
        
        func handleCompletion(accounts: [PlaidAccount], transactions: [PlaidTransaction], nextOffset: Int?) {
            if canceled == nil || canceled?() == false {
                mappedAccounts = accounts
                mappedTransactions.append(contentsOf: transactions)
                
                if let nextOffset = nextOffset {
                    // Recursively get the rest of the transactions
                    pull(offset: nextOffset)
                } else {
                    self.processAccounts(mappedAccounts, institution: institution)
                    self.processTransactions(mappedTransactions, institution: institution, pruneTransactions: pruneTransactions)
                    
                    async { completion?(true, nil) }
                }
            } else {
                async { completion?(true, nil) }
            }
        }
        
        func pull(offset: Int = 0) {
            subscriptionManager.plaidPullAccountsAndTransactions(accessToken: accessToken, offset: offset, startDate: startDate) { success, error, accounts, transactions, nextOffset in
                if success {
                    handleCompletion(accounts: accounts, transactions: transactions, nextOffset: nextOffset)
                } else {
                    log.error("Failed to pull accounts and transactions for \(institution), error: \(String(describing: error))")
                    async { completion?(false, error) }
                }
            }
        }
        
        // Start the (potentially) recursive process
        pull()
    }
   
    static func deleteInstitution(institutionId: Int, completion: SuccessErrorHandler? = nil) {
        guard let institution = InstitutionRepository.si.institution(institutionId: institutionId), let accessToken = institution.accessToken else {
            // TODO: Create proper error object
            completion?(false, nil)
            return
        }

        // Cancel any syncing
        syncManager.cancel()
        
        // Remove the token
        subscriptionManager.plaidDeleteAccessToken(accessToken: accessToken) { _, _ in
            // Delete the local data
            InstitutionRepository.si.delete(institutionId: institutionId)
            
            async { completion?(true, nil) }
        }
    }
    
    //
    // MARK: - Process Models
    //
    
    fileprivate static func processCategories(_ plaidCategories: [PlaidCategory]) {
        // Add/update categories
        for pc in plaidCategories {
            // Get category names
            let count = pc.hierarchy.count
            let name1: String = pc.hierarchy[0]
            let name2: String? = count > 1 ? pc.hierarchy[1] : nil
            let name3: String? = count > 2 ? pc.hierarchy[2] : nil
            
            // Initialize a Category object to insert the record
            _ = CategoryRepository.si.category(source: .plaid, sourceCategoryId: pc.id, name1: name1, name2: name2, name3: name3)
        }
    }
    
    fileprivate static func processAccounts(_ plaidAccounts: [PlaidAccount], institution: Institution) {
        // Add/update accounts
        for pa in plaidAccounts {
            // Convert the balances to cents
            let currentBalance = decimalDollarAmountToCents(pa.current)
            let availableBalance: Int? = pa.available == nil ? nil : decimalDollarAmountToCents(pa.available!)
            
            // Get the account types
            // TODO: Do something when the account type id can't be retreived
            let type = AccountType(plaidString: pa.type)
            let subType: AccountType? = pa.subType == nil ? nil : AccountType(plaidString: pa.subType!)
            
            // Initialize an Account object to insert the record
            let _ = AccountRepository.si.account(institutionId: institution.institutionId, source: .plaid, sourceAccountId: pa.accountId, sourceInstitutionId: institution.sourceInstitutionId, accountTypeId: type, accountSubTypeId: subType, name: pa.name, currency: "USD", currentBalance: currentBalance, availableBalance: availableBalance, number: pa.mask)
        }
        
        // Remove accounts that no longer exist
        // TODO: In the future, when we have metadata associated with accounts / transactions, we'll need to 
        // migrate that metadata to a new account if it is a replacement for an old one. In my case, my Provident
        // Credit Union at some point returned new accounts with new source account ids with better formatted names.
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = plaidAccounts.index(where: {$0.accountId == account.sourceAccountId})
            if index == nil {
                // This account doesn't exist in the plaid response, so remove or hide it
                AccountRepository.si.delete(accountId: account.accountId)
            }
        }
    }
    
    fileprivate static func processTransactions(_ plaidTransactions: [PlaidTransaction], institution: Institution, pruneTransactions: Bool = false) {
        var institutionIds = Set<Int>()
        var pendingSourceTransactionIds = Set<String>()
        var sourceTransactionIds = Set<String>()
        for pt in plaidTransactions {
            // Convert amount to cents
            let amount = decimalDollarAmountToCents(pt.amount)
            
            // Convert date to NSDate
            let date = formatDate(pt.date)
            
            // Get the category id
            var category: Category?
            if let sourceCategoryId = pt.categoryId {
                category = CategoryRepository.si.category(source: .plaid, sourceCategoryId: sourceCategoryId)
            } else if let categoryNames = pt.category {
                let count = categoryNames.count
                let name1: String = categoryNames[0]
                let name2: String? = count > 1 ? categoryNames[1] : nil
                let name3: String? = count > 2 ? categoryNames[2] : nil
                category = CategoryRepository.si.category(source: .plaid, name1: name1, name2: name2, name3: name3)
            }
            
            // Initialize a Transaction object to insert the record
            let transaction = TransactionRepository.si.transaction(source: Source.plaid, sourceTransactionId: pt.transactionId, sourceAccountId: pt.accountId, name: pt.name, currency: "USD", amount: amount, altCurrency: nil, altAmount: nil, date: date, pending: pt.pending, address: pt.address, city: pt.city, state: pt.state, zip: pt.zip, latitude: pt.latitude, longitude: pt.longitude, phone: nil, categoryId: category?.categoryId, institution: institution)
            
            // Record pending transactions to prune records
            if let transaction = transaction, transaction.pending == true {
                pendingSourceTransactionIds.insert(transaction.sourceTransactionId)
            } else if let transaction = transaction {
                sourceTransactionIds.insert(transaction.sourceTransactionId)
                
                // Record all institutionIds to find pending transactions in the db, otherwise if no
                // pending transactions were returned by Plaid, we'll never prune the local ones.
                institutionIds.insert(transaction.institutionId)
            }
        }
        
        var pendingTransactionsFromDb = [Transaction]()
        for institutionId in institutionIds {
            let transactions = TransactionRepository.si.transactions(institutionId: institutionId, pending: true)
            pendingTransactionsFromDb.append(contentsOf: transactions)
        }
        
        for transaction in pendingTransactionsFromDb {
            if !pendingSourceTransactionIds.contains(transaction.sourceTransactionId) {
                // This pending transaction no longer exists (either it was just an authorization 
                // or it has been replaced by a non-pending transaction)
                transaction.delete()
            }
        }
        
        if pruneTransactions {
            // Remove transactions that no longer exist
            var transactionsFromDb = [Transaction]()
            for institutionId in institutionIds {
                let transactions = TransactionRepository.si.transactions(institutionId: institutionId, pending: false)
                transactionsFromDb.append(contentsOf: transactions)
            }
            
            for transaction in transactionsFromDb {
                if !sourceTransactionIds.contains(transaction.sourceTransactionId) {
                    // This transaction no longer exists (it has probably been updated with new metadata and
                    // given a new transaction id)
                    transaction.delete()
                }
            }
        }
    }
}
