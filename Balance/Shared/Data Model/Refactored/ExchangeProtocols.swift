//
//  ExchangeApi2.swift
//  Balance
//
//  Created by Benjamin Baron on 1/22/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public typealias ExchangeApiOperationCompletionHandler = (_ success: Bool, _ error: ExchangeError?, _ data: [Any]) -> Void

public enum ExchangeError: Error {
    case invalidCredentials
    case other
}

public protocol ExchangeApi2 {
    func fetchData(for action: APIAction, completion: @escaping ExchangeApiOperationCompletionHandler) -> Operation
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
