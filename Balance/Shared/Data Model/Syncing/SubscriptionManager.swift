//
//  SubscriptionManager.swift
//  Bal
//
//  Created by Benjamin Baron on 11/1/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import SwiftyStoreKit

typealias Completion = (_ success: Bool, _ errorMessage: String, _ error: Error?) -> (Void)
typealias ValidationCompletion = (_ code: BalanceServerCode, _ remainingAccounts: Int, _ accessTokens: [String: String]?) -> (Void)
typealias PlaidTransactionsCompletion = (_ success: Bool, _ error: Error?, _ plaidAccounts: [PlaidAccount], _ plaidTransactions: [PlaidTransaction], _ nextOffset: Int?) -> (Void)


#if DEBUG
let subServerBaseUrl = debugging.useLocalSubscriptionServer ? "http://localhost:8080" : "https://bal-subscription-server-beta.appspot.com"
#else
let subServerBaseUrl = betaOptionsEnabled ? "https://bal-subscription-server-beta.appspot.com" : "https://www.balancemysubscription.com"
#endif

enum BalanceServerCode: Int, Error, CustomStringConvertible {
    case success             = 0
    case invalidReceipt      = 1
    case subscriptionExpired = 2
    case networkError        = 3
    case databaseError       = 4
    case unknownError        = 5
    case accountLimitReached = 6
    case plaidAPIError       = 7
    case invalidInputData    = 8
    case emailSendError      = 9
    case jsonParsingError    = 10
    
    var message: String {
        switch self {
        case .success:             return "Success"
        case .invalidReceipt:      return "Invalid receipt"
        case .subscriptionExpired: return "Subscription expired"
        case .networkError:        return "Network error"
        case .databaseError:       return "Database error"
        case .accountLimitReached: return "Account limit reached"
        case .plaidAPIError:       return "Plaid API error"
        case .invalidInputData:    return "Invalid input data"
        case .emailSendError:      return "Error sending email"
        case .jsonParsingError:    return "JSON Parsing error"
        default:                   return "Unkown error"
        }
    }
    
    var description: String {
        return "\(rawValue) - \(message)"
    }
}

class SubscriptionManager {
    
    struct Keys {
        static let Code = "code"
        static let Message = "message"
        static let AccessTokens = "accessTokens"
        static let SourceInstitutionIds = "sourceInstitutionIds"
        static let RemainingTokens = "remainingTokens"
        static let ProductId = "productId"
        static let ExpirationDate = "expirationDate"
        static let ShowInIntro = "showInIntro"
        static let ShowForExistingSubscribers = "showForExistingSubscribers"
        static let RealmUser = "realmUser"
        static let RealmPass = "realmPass"
    }
    
    //
    // MARK: - Properties -
    //
    
    fileprivate let connectionTimeout = 30.0
    fileprivate let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
    
    fileprivate var hasShownErrorAlert = false
    
    var hasReceipt: Bool {
        return receiptData != nil
    }
    
    var receiptData: Data? {
        if debugging.disableSubscription {
            return nil
        } else {
            #if DEBUG
                let receiptString = debugging.personalAppStoreReceipt
                return Data(base64Encoded: receiptString)
            #else
                if let receiptUrl = Bundle.main.appStoreReceiptURL {
                    do {
                        let receiptData = try Data(contentsOf: receiptUrl)
                        return receiptData
                    } catch {
                        if error.domain == NSCocoaErrorDomain && error.code == 260 {
                            log.debug("No receipt data exists")
                        } else {
                            log.error("error reading receiptData: \(error)")
                        }
                    }
                }
                return nil
            #endif
        }
    }
    
    var productId: ProductId {
        if isExpired {
            return .none
        } else {
            let dict = subscriptionInfo
            if let productIdString = dict[Keys.ProductId] as? String, let productId = ProductId(rawValue: productIdString) {
                return productId
            } else {
                return .none
            }
        }
    }
    
    var maxAccounts: Int {
        return productId.maxAccounts
    }
    
    var remainingAccounts: Int {        
        return subscriptionInfo[Keys.RemainingTokens] as? Int ?? 0
    }
    
    var expirationDate: Date {
        return subscriptionInfo[Keys.ExpirationDate] as? Date ?? Date.distantPast
    }
    
    var isExpired: Bool {
        return Date().timeIntervalSince(expirationDate) > 0
    }
    
    var realmUser: String? {
        if let realmUser = subscriptionInfo[Keys.RealmUser] as? String, realmUser.length > 0 {
            return realmUser
        }
        return nil
    }
    
    var realmPass: String? {
        if let realmPass = subscriptionInfo[Keys.RealmPass] as? String, realmPass.length > 0 {
            return realmPass
        }
        return nil
    }
    
    var showLightPlanInIntro = false
    var showLightPlanForExistingSubscribers = false
    var showLightPlanInPreferences: Bool {
        return productId == .lightMonthly || showLightPlanForExistingSubscribers
    }
    
    fileprivate var subscriptionInfo: [String: Any] {
        get {
            var dict = [String: Any]()
            
            if (debugging.disableSubscription || receiptData != nil), let base64 = keychain[KeychainAccounts.Subscription, KeychainKeys.InfoDictionary] {
                if let data = Data(base64Encoded: base64, options: []) {
                    do {
                        try ObjC.catchException {
                            dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] ?? [String: Any]()
                        }
                    } catch {
                        return dict
                    }
                }
            }
            
            return dict
        }
        set {
            if let remainingTokens = newValue[Keys.RemainingTokens] as? Int, let productId = newValue[Keys.ProductId] as? String {
                if remainingTokens == 0 && productId != ProductId.none.rawValue {
                    print("this should never happen")
                }
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            let base64 = data.base64EncodedString(options: [])
            keychain[KeychainAccounts.Subscription, KeychainKeys.InfoDictionary] = base64
        }
    }
    
    init() {
        if debugging.disableSubscription && (realmUser == nil || realmPass == nil) {
            // Initialize realm credentials
            var dict = [String: Any]()
            dict[Keys.RealmUser] = String.random(64)
            dict[Keys.RealmPass] = String.random(64)
            subscriptionInfo = dict
        }
    }
    
    // 
    // MARK: - App Store -
    //
    
    func subscribe(productId: ProductId, completion: @escaping Completion) {
        SwiftyStoreKit.purchaseProduct(productId.rawValue) { result in
            switch result {
            case .success(let productId):
                self.validateReceipt { code, _, _ in
                    if code == .success {
                        completion(true, "", nil)
                    } else {
                        log.error("Failed to register receipt with subscription server: \(code)")
                        completion(false, code.message, code)
                    }
                }
                log.debug("Purchase Success: \(productId)")
            case .error(let error):
                // Because the App Store developers are incompetent, when a user tries to subscribe
                // and they already have a subscription, they get a dialog saying they're already
                // subscribed, but we get an error /facepalm...
                // So before displaying an error to the user, first try to restore the subscription automatically
                self.restoreSubscription { success, restoreError in
                    if success {
                        self.validateReceipt { code, _, _ in
                            if code == .success {
                                completion(true, "", nil)
                            } else {
                                log.error("Failed to validate receipt with subscription server when restoring subscription: \(code)")
                                completion(false, code.message, code)
                            }
                        }
                        log.debug("Purchase Success: \(productId)")
                    } else {
                        var errorMessage = ""
                        var returnError: Error?
                        switch error {
                        case .failed(let cocoaError):
                            errorMessage = cocoaError.localizedDescription
                            returnError = cocoaError
                        case .invalidProductId(let productId):
                            errorMessage = "Invalid product ID: \(productId)"
                        case .paymentNotAllowed:
                            errorMessage = "The payment was not allowed"
                        }
                        
                        async { completion(false, errorMessage, returnError) }
                        log.error("Purchase Failed: \(error)")
                    }
                }
            }
        }
    }
    
    func completeTransactions() {
        if debugging.disableSubscription {
            return
        }
        
        SwiftyStoreKit.completeTransactions { products in
            print("purchased: \(products)")
            if let product = products.first {
                let state = product.transaction.transactionState
                if state == .purchased || state == .restored {
                    // Validate the receipt before returning
                    self.validateReceipt { code, _, _ in
                        if code == .success {
                            let userInfo = [Notifications.Keys.ProductId: product.productId]
                            NotificationCenter.postOnMainThread(name: Notifications.ProductPurchased, object: nil, userInfo: userInfo)
                        }
                    }
                }
            }
        }
    }
    
    typealias RestoreCompletion = (_ success: Bool, _ error: Error?) -> (Void)
    func restoreSubscription(completion: @escaping RestoreCompletion) {
        SwiftyStoreKit.refreshReceipt { result in
            switch result {
            case .success:
            // Validate the receipt before returning
            log.debug("Success refreshing receipt")
            self.validateReceipt(showErrorAlert: false) { code, _, _ in
                let success = (code == .success)
                let error = success ? nil : code
                completion(success, error)
            }
            case .error(let error):
                log.error("Error refreshing receipt: \(error)")
                async { completion(false, error) }
            }
        }
    }
    
    // Contacts the subscription server, handles any differences in access tokens (adds/removes accounts), and returns success and remaining accounts
    func validateReceipt(showErrorAlert: Bool = true, completion: @escaping ValidationCompletion) {
        if debugging.disableSubscription {
            async { completion(.success, 0, nil) }
            return
        }
        
        guard let receiptData = receiptData else {
            log.error("Failed to validate receipt, because no receipt existed")
            async { completion(.unknownError, 0, nil) }
            return
        }
        
        let url = URL(string: "\(subServerBaseUrl)/verify")!
        let body = "{\"receiptData\":\"\(receiptData.base64EncodedString())\"}"
        let request = jsonUrlRequest(url: url, jsonData: body.data(using: .utf8)!)
        let task = session.dataTask(with: request) { maybeData, _, error in
            // Make sure there's data
            guard let data = maybeData, error == nil else {
                log.error("Failed to validate receipt. There was no data returned or there was an error. data == nil: \(maybeData == nil), error: \(String(describing: error))")
                async { completion(.networkError, 0, nil) }
                return
            }
            
            // Try to parse the JSON
            guard var jsonResult = self.dictionaryFromJsonData(data), let codeInt = jsonResult[Keys.Code] as? Int, let code = BalanceServerCode(rawValue: codeInt) else {
                log.error("Failed to validate receipt. Failed to parse the JSON.")
                async { completion(.jsonParsingError, 0, nil) }
                return
            }
            
            // Process the response
            let accessTokens = jsonResult[Keys.AccessTokens] as? [String]
            let sourceInstitutionIds = jsonResult[Keys.SourceInstitutionIds] as? [String]
            let remainingTokens = jsonResult[Keys.RemainingTokens] as? Int
            let expirationDateString = jsonResult[Keys.ExpirationDate] as? String
            var expirationDate: Date?
            if let expirationDateString = expirationDateString {
                expirationDate = jsonDateFormatter.date(from: expirationDateString)
                if let expirationDate = expirationDate {
                    jsonResult[Keys.ExpirationDate] = expirationDate
                }
            }
            
            if code == .success, let accessTokens = accessTokens, let sourceInstitutionIds = sourceInstitutionIds, let remainingTokens = remainingTokens, let expirationDate = expirationDate {
                // Store the subscription info
                self.subscriptionInfo = jsonResult
                
                realmManager.authenticate { success, error in
                    if success {
                        NotificationCenter.postOnMainThread(name: Notifications.RealmAuthenticated)
                    }
                }
                
                var accessTokensSourceInstitutionIds = [String: String]()
                for (index, accessToken) in accessTokens.enumerated() {
                    accessTokensSourceInstitutionIds[accessToken] = sourceInstitutionIds[index]
                }
                
                // Call the handler
                log.debug("Successfully validated receipt, remainingTokens: \(remainingTokens), productId: \(self.productId),  expirationDate: \(expirationDate)")
                if self.productId == .none {
                    self.handleNoSubscription(showErrorAlert: showErrorAlert, code: code, completion: completion)
                } else {
                    async {
                        self.hasShownErrorAlert = false
                        completion(code, remainingTokens, accessTokensSourceInstitutionIds)
                    }
                }
            } else if code == .invalidReceipt {
                // Store the subscription info
                self.subscriptionInfo = jsonResult
                
                // The receipt is not valid (maybe they tried cracking it)
                log.debug("The receipt is invalid.")
                self.handleNoSubscription(showErrorAlert: showErrorAlert, code: code, completion: completion)
            } else if code == .subscriptionExpired {
                // Store the subscription info
                self.subscriptionInfo = jsonResult
                
                // The subscription was valid but is expired
                log.debug("The subscription has expired")
                self.handleNoSubscription(showErrorAlert: showErrorAlert, code: code, completion: completion)
            } else {
                // Some kind of connection error
                log.debug("Failed to validate receipt. The JSON parsed, but data was missing.")
                async {
                    completion(code, 0, nil)
                }
            }
        }
    
        task.resume()
    }

    fileprivate func handleNoSubscription(showErrorAlert: Bool, code: BalanceServerCode, completion: @escaping ValidationCompletion) {
        async {
            completion(code, 0, nil)
            
            // Delete data
            let institutions = InstitutionRepository.si.allInstitutions()
            for institution in institutions {
                institution.delete()
            }
            
            async(after: 2.0) {
                if showErrorAlert && !self.hasShownErrorAlert {
                    if code == .invalidReceipt {
                        self.showValidationErrorAlert(type: .invalidReceipt)
                    } else if code == .subscriptionExpired {
                        self.showValidationErrorAlert(type: .expiredSubscription)
                    }
                    self.hasShownErrorAlert = true
                }
                NotificationCenter.postOnMainThread(name: Notifications.ShowIntro)
            }
        }
    }
    
    func updatePrices() {
        if debugging.disableSubscription {
            return
        }
        
        let productIds = Set<String>([ProductId.lightMonthly.rawValue, ProductId.basicMonthly.rawValue, ProductId.basicAnnual.rawValue, ProductId.mediumMonthly.rawValue, ProductId.mediumAnnual.rawValue, ProductId.proMonthly.rawValue, ProductId.proAnnual.rawValue])
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            var priceDictionary = [ProductId: Int]()
            for product in result.retrievedProducts {
                if let productId = ProductId(rawValue: product.productIdentifier) {
                    let behavior = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
                    let dollars = product.price.rounding(accordingToBehavior: behavior)
                    let cents = product.price.subtracting(dollars).multiplying(byPowerOf10: 2)
                    let centsInt = (Int(truncating: dollars) * 100) + Int(truncating: cents)
                    priceDictionary[productId] = centsInt
                }
            }
            
            if priceDictionary.count == productIds.count {
                ProductId.priceDictionary = priceDictionary
            }
        }
    }
    
    //
    // MARK: - Plaid -
    //
    
    func plaidExchangePublicToken(sourceInstitutionId: String, publicToken: String, completion: SuccessErrorHandler? = nil) {
        guard let receiptData = subscriptionManager.receiptData else {
            log.debug("Failed to exchange plaid token, because no receipt exists")
            async { completion?(false, BalanceError.noReceipt) }
            return
        }
        
        let parameters: [String: String] = ["receiptData": receiptData.base64EncodedString(),
                                            "accessToken": publicToken,
                                            "sourceInstitutionId": sourceInstitutionId]
        guard let jsonData = jsonDataFromDictionary(parameters) else {
            log.debug("Failed to exchange plaid token, JSON body could not be created")
            async { completion?(false, BalanceError.jsonEncoding) }
            return
        }

        let url = URL(string: "\(subServerBaseUrl)/plaid/exchangePublicToken")!
        let request = jsonUrlRequest(url: url, jsonData: jsonData)

        let task = session.dataTask(with: request) { maybeData, _, error in
            // Make sure there's data
            guard let data = maybeData, error == nil else {
                log.debug("Failed to delete access token. There was no data returned or there was an error. Error: \(String(describing: error))")
                let returnError = maybeData == nil ? BalanceError.noData : error
                async { completion?(false, returnError) }
                return
            }
            
            // Try to parse the JSON
            guard let jsonResult = self.dictionaryFromJsonData(data), let codeInt = jsonResult[Keys.Code] as? Int, let code = BalanceServerCode(rawValue: codeInt) else {
                log.debug("Failed to delete plaid access token. Failed to parse the JSON.")
                async { completion?(false, BalanceError.jsonDecoding) }
                return
            }
            
            // Process the response
            let accessTokens = jsonResult[Keys.AccessTokens] as? [String]
            let sourceInstitutionIds = jsonResult[Keys.SourceInstitutionIds] as? [String]
            let remainingTokens = jsonResult[Keys.RemainingTokens] as? Int
            
            if code == .success, let accessTokens = accessTokens, let sourceInstitutionIds = sourceInstitutionIds, let remainingTokens = remainingTokens {
                // Update remaining tokens
                var info = self.subscriptionInfo
                info[Keys.RemainingTokens] = remainingTokens
                self.subscriptionInfo = info
                
                var accessTokensSourceInstitutionIds = [String: String]()
                for (index, accessToken) in accessTokens.enumerated() {
                    accessTokensSourceInstitutionIds[accessToken] = sourceInstitutionIds[index]
                }
                
                async {
                    syncManager.syncAccessTokens(accessTokensSourceInstitutionIds)
                    syncManager.sync()
                    completion?(true, nil)
                }
            } else {
                log.error("Failed to exchange plaid public token: \(code)")
                async { completion?(false, code) }
            }
        }

        task.resume()
    }

    func plaidDeleteAccessToken(accessToken: String, completion: SuccessErrorHandler? = nil) {
        guard let receiptData = subscriptionManager.receiptData else {
            log.debug("Failed to delete plaid access token, because no receipt exists")
            async { completion?(false, BalanceError.noReceipt) }
            return
        }
        
        let parameters: [String: String] = ["receiptData": receiptData.base64EncodedString(),
                                            "accessToken": accessToken]
        guard let jsonData = jsonDataFromDictionary(parameters) else {
            log.debug("Failed to delete plaid token, JSON body could not be created")
            async { completion?(false, BalanceError.jsonEncoding) }
            return
        }
        
        let url = URL(string: "\(subServerBaseUrl)/plaid/deleteAccessToken")!
        let request = jsonUrlRequest(url: url, jsonData: jsonData)
        let task = session.dataTask(with: request) { maybeData, _, error in
            // Make sure there's data
            guard let data = maybeData, error == nil else {
                log.debug("Failed to delete plaid access token. There was no data returned or there was an error. Error: \(String(describing: error))")
                let returnError = maybeData == nil ? BalanceError.noData : error
                async { completion?(false, returnError) }
                return
            }
            
            // Try to parse the JSON
            guard let jsonResult = self.dictionaryFromJsonData(data), let codeInt = jsonResult[Keys.Code] as? Int, let code = BalanceServerCode(rawValue: codeInt) else {
                log.debug("Failed to delete plaid access token. Failed to parse the JSON.")
                async { completion?(false, BalanceError.jsonDecoding) }
                return
            }
            
            // Handle the response
            if code == .success, let remainingTokens = jsonResult[Keys.RemainingTokens] as? Int {
                var info = self.subscriptionInfo
                info[Keys.RemainingTokens] = remainingTokens
                self.subscriptionInfo = info
                
                log.debug("Successfully deleted plaid access token, remainingTokens: \(remainingTokens)")
                async { completion?(true, nil) }
            } else {
                log.error("Failed to delete plaid access token: \(code)")
                async { completion?(false, code) }
            }
        }
        
        task.resume()
    }
    
    func plaidPullAccountsAndTransactions(accessToken: String, offset: Int = 0, startDate: Date? = nil, completion: @escaping PlaidTransactionsCompletion) {
        guard let receiptData = subscriptionManager.receiptData else {
            log.debug("Failed to pull accounts and transactions, because no receipt exists")
            async { completion(false, BalanceError.noReceipt, [], [], nil) }
            return
        }
        
        let parameters: [String: Any] = ["receiptData": receiptData.base64EncodedString(),
                                         "accessToken": accessToken,
                                         "offset": offset,
                                         "startDateTimestamp": startDate?.timeIntervalSince1970 ?? 0]
        guard let jsonData = jsonDataFromDictionary(parameters) else {
            log.debug("Failed to pull accounts and transactions, JSON body could not be created")
            async { completion(false, BalanceError.jsonEncoding, [], [], nil) }
            return
        }
        
        let url = URL(string: "\(subServerBaseUrl)/plaid/proxyAccountsAndTransactions")!
        let request = jsonUrlRequest(url: url, jsonData: jsonData)
        let task = session.dataTask(with: request) { maybeData, _, error in
            // Make sure there's data
            guard let data = maybeData, error == nil else {
                log.error("Failed to pull accounts and transactions, no data returned")
                let returnError = maybeData == nil ? BalanceError.noData : error
                async { completion(false, returnError, [], [], nil) }
                return
            }
            
            // Try to parse the JSON
            guard let jsonResult = self.dictionaryFromJsonData(data) else {
                log.error("Failed to pull accounts and transactions, invalid JSON")
                async { completion(false, BalanceError.jsonDecoding, [], [], nil) }
                return
            }
            
            // Check for a Balance server error
            if let codeInt = jsonResult[Keys.Code] as? Int, let code = BalanceServerCode(rawValue: codeInt) {
                log.error("Failed to pull accounts and transactions. Subscription server error: \(code)")
                async { completion(false, code, [], [], nil) }
                return
            }
            
            // Try to parse the Plaid JSON
            guard let accounts = jsonResult["accounts"] as? [[String: AnyObject]], let transactions = jsonResult["transactions"] as? [[String: AnyObject]], let totalTransactions = jsonResult["total_transactions"] as? Int else {
                // Check for Plaid error codes
                if let errorType = jsonResult["errorType"] as? String, let errorCode = jsonResult["errorCode"] as? String {
                    // TODO: Handle this
                    log.error("Failed to pull accounts and transactions, Plaid API error: \(errorType) - \(errorCode)")
                    async { completion(false, BalanceError.plaidApiError, [], [], nil) }
                } else {
                    log.error("Failed to pull accounts and transactions, invalid Plaid JSON")
                    async { completion(false, BalanceError.plaidApiError, [], [], nil) }
                }
                return
            }
            
            // Map the accounts
            var mappedAccounts = [PlaidAccount]()
            for pa in accounts {
                do {
                    let account = try PlaidAccount(account: pa)
                    mappedAccounts.append(account)
                } catch {
                    log.error("Error parsing plaid account: \(error)")
                }
            }
            
            // Map the transactions
            var mappedTransactions = [PlaidTransaction]()
            for pt in transactions {
                do {
                    let transaction = try PlaidTransaction(transaction: pt)
                    mappedTransactions.append(transaction)
                } catch {
                    log.error("Error parsing plaid transaction: \(error)")
                }
            }
            
            // Finish
            async {
                let remainingTransactions = totalTransactions - transactions.count
                let nextOffset: Int? = remainingTransactions > 0 ? offset + transactions.count : nil
                completion(true, nil, mappedAccounts, mappedTransactions, nextOffset)
            }
        }
        
        task.resume()
    }
    
    //
    // MARK: - Error Handling -
    //
    
    fileprivate struct ErrorMessages {
        static let Success = "Your subscription is valid"
        static let NoSubscription = "You do not have a subscription"
        static let NoReceiptData = "There is no subscription receipt"
        static let NoData = "There was an problem validating your subscription. We didn't receive a response back. Please try again."
        static let InvalidReceipt = "The receipt is invalid"
        static let SubscriptionExpired = "The subscription has expired"
        static let PlaidError = "There was a problem with Plaid, our account connection service. Please try again."
    }
    
    fileprivate enum ValidationErrorAlertType {
        case invalidReceipt
        case expiredSubscription
    }
    
    fileprivate let errorDateFormatter: DateFormatter = {
        let errorDateFormatter = DateFormatter()
        errorDateFormatter.dateFormat = "MMMM d, yyyy"
        return errorDateFormatter
    }()
    
    fileprivate func showValidationErrorAlert(type: ValidationErrorAlertType) {
        #if os(OSX)
        var messageText = ""
        var informativeText = ""
        switch type {
        case .invalidReceipt:
            messageText = "Invalid Receipt"
            informativeText = "Your iTunes receipt is not valid."
        case .expiredSubscription:
            messageText = "Expired Subscription"
            let formattedDate = errorDateFormatter.string(from: expirationDate)
            informativeText = "Your subscription expired on \(formattedDate).\n\nPlease resubscribe to continue using Balance."
        }
        
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.alertStyle = .informational
        alert.runModal()
        #else
        // TODO: Implement for iOS
        #endif
    }
    
    //
    // MARK: - JSON helpers -
    //
    
    fileprivate func jsonDataFromDictionary(_ dictionary: [String: Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return jsonData
        } catch {
            log.error("Error serializing JSON data: \(error)")
            return nil
        }
    }
    
    fileprivate func jsonUrlRequest(url: URL, jsonData: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = HTTPMethod.POST
        request.httpBody = jsonData
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appBuildString, forHTTPHeaderField: "X-Balance-Build")
        return request
    }
    
    fileprivate func dictionaryFromJsonData(_ data: Data) -> [String: Any]? {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            return jsonResult
        } catch {
            log.error("Error deserializing JSON data: \(error)")
            return nil
        }
    }
}
