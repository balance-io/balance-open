//
//  ExchangeApi2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public typealias ExchangeApiOperationCompletionHandler = (_ success: Bool, _ error: BaseError?, _ data: [Any]) -> Void

public protocol ExchangeApi2 {
    func getAccounts(completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation
    func getTransactions(completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation
}

extension ExchangeApi2 {
    
    func processBaseErrors(response: HTTPURLResponse?, error: Error?) -> Error? {
        if let error = error as NSError?, error.code == -1009 {
            return BaseError.internetConnection
        }
        
        guard let statusCode = response?.statusCode else {
            return nil
        }
        
        switch statusCode {
        case 400...499:
            return BaseError.invalidCredentials(statusCode: statusCode)
        case 500...599:
            return BaseError.invalidServer(statusCode: statusCode)
        default:
            return nil
        }
    }
    
    func dataToJSON(data: Data?) -> [AnyHashable: Any]? {
        guard let data = data,
            let rawData = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        
        return rawData as? [AnyHashable: Any]
    }
    
}


public protocol ExchangeInstitution {
    var source: Source { get }
    var name: String { get}
    var fields: [Field] { get }
}

public protocol ExchangeAccount {
    var institutionId: Int { get }
    var source: Source { get }
    var sourceAccountId: String { get }
    var name: String { get }
    var currencyCode: String { get }
    var currentBalance: Int { get }
    var availableBalance: Int { get }
    var altCurrencyCode: String? { get }
    var altCurrentBalance: Int? { get }
    var altAvailableBalance: Int? { get }
}

public protocol ExchangeTransaction {
    var category: TransactionType { get }
    var institutionId: Int { get }
    var source: Source { get }
    var sourceInstitutionId: String { get }
    var sourceAccountId: String { get }
    var sourceTransactionId: String { get }
    var name: String { get }
    var date: Date { get } // UTC
    var currencyCode: String { get }
    var amount: Int { get }
}

/*
 * These would go in the app, the above would go in the framework
 */

func processExchangeAccounts(_ accounts: [ExchangeAccount]) {
    for account in accounts {
        // Initialize an Account object to insert the record
        AccountRepository.si.account(institutionId: account.institutionId, source: account.source, sourceAccountId: account.sourceAccountId, sourceInstitutionId: "", accountTypeId: .exchange, accountSubTypeId: nil, name: account.name, currency: account.currencyCode, currentBalance: account.currentBalance, availableBalance: account.availableBalance, number: nil, altCurrency: account.altCurrencyCode, altCurrentBalance: account.altCurrentBalance, altAvailableBalance: account.altAvailableBalance)
    }
}

func processExchangeTransactions(_ transactions: [ExchangeTransaction]) {
    for transaction in transactions {
        TransactionRepository.si.transaction(source: transaction.source, sourceTransactionId: transaction.sourceInstitutionId, sourceAccountId: transaction.sourceAccountId, name: transaction.name, currency: transaction.currencyCode, amount: transaction.amount, date: transaction.date, categoryID: nil, sourceInstitutionId: transaction.sourceInstitutionId, institutionId: transaction.institutionId)
    }
}
