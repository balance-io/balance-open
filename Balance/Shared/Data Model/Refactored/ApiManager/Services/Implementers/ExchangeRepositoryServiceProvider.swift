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
    
    func createAccounts(for source: Source, accounts: [ExchangeAccount], institution: Institution) {
        switch source {
        case .poloniex:
            savePoloniexAccounts(accounts: accounts, institution: institution)
        default:
            return
        }
    }
    
    func createTransactions(for source: Source, transactions: [ExchangeTransaction]) {
        saveExchangeTransactions(transactions)
    }
    
}

private extension ExchangeRepositoryServiceProvider {
    
    func savePoloniexAccounts(accounts: [ExchangeAccount], institution: Institution) {
        //TODO: FELIPE update accounts with the institution if needed
        hideLocalAccounts(accounts)
        
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = accounts.index(where: {$0.currency == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
    func hideLocalAccounts(_ accounts: [ExchangeAccount]) {
        for exchangeAccount in accounts {
            guard let accountSaved = saveExchangeAccount(exchangeAccount) else {
                continue
            }
            
            //TODO: validate if currenty property on Poloniex account is equal with currencyCode from ExchangeAccount protocol
            let currency = Currency.rawValue(exchangeAccount.currencyCode)
            let isHidden = (exchangeAccount.currentBalance == 0)
            
            guard currency != Currency.btc,
                currency != Currency.eth,
                accountSaved.isHidden != isHidden else {
                    return
            }
            
            accountSaved.isHidden = isHidden
        }
    }
    
}

private extension ExchangeRepositoryServiceProvider {

    @discardableResult func saveExchangeAccount(_ account: ExchangeAccount) -> Account? {
        return AccountRepository.si.account(institutionId: account.institutionId,
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
    
    @discardableResult func saveExchangeTransaction(_ transaction: ExchangeTransaction) -> Transaction? {
        return TransactionRepository.si.transaction(source: transaction.source,
                                             sourceTransactionId: transaction.sourceInstitutionId,
                                             sourceAccountId: transaction.sourceAccountId,
                                             name: transaction.name,
                                             currency: transaction.currencyCode,
                                             amount: transaction.amount, //TODO: use amountWithDecimals instead normal amount and each exchange transaction must validate if has to return with decimals or not
                                             date: transaction.date,
                                             categoryID: nil,
                                             sourceInstitutionId: transaction.sourceInstitutionId,
                                             institutionId: transaction.institutionId)
    }
    
    @discardableResult func saveExchangeAccounts(_ accounts: [ExchangeAccount]) -> [Account] {
        return accounts.flatMap { self.saveExchangeAccount($0) }
    }
    
    @discardableResult func saveExchangeTransactions(_ transactions: [ExchangeTransaction]) -> [Transaction] {
        return transactions.flatMap { self.saveExchangeTransaction($0) }
    }
    
}
