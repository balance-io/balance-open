//
//  ExchangeRepositoryServiceProvider.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeRepositoryServiceProvider: RepositoryServiceProtocol {
    
    func createInstitution(for source: Source) -> Institution? {
        return InstitutionRepository.si.institution(source: source, sourceInstitutionId: "", name: source.description)
    }
    
    func processAccounts(for source: Source, accounts: [ExchangeAccount], institution: ExchangeInstitution) {
        
    }
    
    func processTransactions(for source: Source, transactions: [ExchangeTransaction]) {
        
    }
    
}

private extension ExchangeRepositoryServiceProvider {
    
    func saveExchangeAccounts(_ accounts: [ExchangeAccount]) {
        for account in accounts {
            AccountRepository.si.account(institutionId: account.institutionId,
                                         source: account.source,
                                         sourceAccountId: account.sourceAccountId,
                                         sourceInstitutionId: "",
                                         accountTypeId: .exchange,
                                         accountSubTypeId: nil,
                                         name: account.name,
                                         currency: account.currencyCode,
                                         currentBalance: account.currentBalance,
                                         availableBalance: account.availableBalance,
                                         number: nil,
                                         altCurrency: account.altCurrencyCode,
                                         altCurrentBalance: account.altCurrentBalance,
                                         altAvailableBalance: account.altAvailableBalance)
        }
    }
    
    func saveExchangeTransactions(_ transactions: [ExchangeTransaction]) {
        for transaction in transactions {
            TransactionRepository.si.transaction(source: transaction.source,
                                                 sourceTransactionId: transaction.sourceInstitutionId,
                                                 sourceAccountId: transaction.sourceAccountId,
                                                 name: transaction.name,
                                                 currency: transaction.currencyCode,
                                                 amount: transaction.amount,
                                                 date: transaction.date,
                                                 categoryID: nil,
                                                 sourceInstitutionId: transaction.sourceInstitutionId,
                                                 institutionId: transaction.institutionId)
        }
    }
    
}
