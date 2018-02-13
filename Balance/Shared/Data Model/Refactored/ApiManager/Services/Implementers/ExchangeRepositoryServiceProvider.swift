//
//  ExchangeRepositoryServiceProvider.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/25/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class ExchangeRepositoryServiceProvider: RepositoryServiceProtocol {
    
    func createInstitution(for source: Source, name: String) -> Institution? {
        return InstitutionRepository.si.institution(source: source, sourceInstitutionId: "", name: !name.isEmpty ? name : source.description)
    }
    
    func createAccounts(for source: Source, accounts: [ExchangeAccount], institution: Institution) {
        let accountsUpdated = updateAccounts(accounts, with: institution)
        
        switch source {
        case .kraken, .gdax, .bitfinex, .blockchain, .bittrex, .hitbtc:
            saveExchangeAccounts(accountsUpdated)
        case .binance:
            saveAndHideLocalAccounts(accountsUpdated)
        case .poloniex:
            savePoloniexAccounts(accountsUpdated, institution: institution)
        case .coinbase:
            saveCoinbaseAccounts(accountsUpdated, institution: institution)
        case .ethplorer:
            saveEthplorerAccounts(accountsUpdated, institution: institution)
        }
        
    }
    
    func createTransactions(for source: Source, transactions: [ExchangeTransaction], institution: Institution) {
        let transactionsUpdated = updateTransactions(transactions, institution: institution)
        saveExchangeTransactions(transactionsUpdated)
    }
    
}

//TODO: Refactor the way for deleting an account(account not used). Look all the implementation are very similar the only diference is the index implementation. "if index == nil"
//mark: Ethplorer
private extension ExchangeRepositoryServiceProvider {

    func saveEthplorerAccounts(_ accounts: [ExchangeAccount], institution: Institution) {
        saveExchangeAccounts(accounts)
        
        let savedAccounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in savedAccounts {
            let index = accounts.index(where: {$0.currencyCode == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
}

//mark: Coinbase
private extension ExchangeRepositoryServiceProvider {
    
    func saveCoinbaseAccounts(_ accounts: [ExchangeAccount], institution: Institution) {
        saveExchangeAccounts(accounts)
        let savedAccounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        
        for account in savedAccounts {
            let index = accounts.index(where: {$0.sourceAccountId == account.sourceAccountId})
            if index == nil {
                // This account doesn't exist in the coinbase response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
}

//mark: Poloniex
private extension ExchangeRepositoryServiceProvider {
    
    func savePoloniexAccounts(_ accounts: [ExchangeAccount], institution: Institution) {
        saveAndHideLocalAccounts(accounts)
         
        let accounts = AccountRepository.si.accounts(institutionId: institution.institutionId)
        for account in accounts {
            let index = accounts.index(where: {$0.currency == account.currency})
            if index == nil {
                // This account doesn't exist in the response, so remove it
                AccountRepository.si.delete(account: account)
            }
        }
    }
    
    func saveAndHideLocalAccounts(_ accounts: [ExchangeAccount]) {
        for exchangeAccount in accounts {
            guard let accountSaved = saveExchangeAccount(exchangeAccount) else {
                continue
            }
            
            let currency = Currency.rawValue(exchangeAccount.currencyCode)
            let isHidden = (exchangeAccount.currentBalance == 0)
            
            guard currency != Currency.btc,
                currency != Currency.eth,
                accountSaved.isHidden != isHidden else {
                    continue
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
                                            accountTypeId: account.accountType,
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
                                                    sourceTransactionId: transaction.sourceTransactionId,
                                                    sourceAccountId: transaction.sourceAccountId,
                                                    name: transaction.name,
                                                    currency: transaction.currencyCode,
                                                    amount: transaction.amount,
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

    func updateAccounts(_ accounts: [ExchangeAccount], with institution: Institution) -> [ExchangeAccount] {
        return accounts.map({ (account) -> ExchangeAccount in
            var account = account
            account.institutionId = institution.institutionId
            
            return account
        })
    }
    
    func updateTransactions(_ transactions: [ExchangeTransaction], institution: Institution) -> [ExchangeTransaction] {
        return transactions.map({ (transaction) -> ExchangeTransaction in
            var transaction = transaction
            transaction.institutionId = institution.institutionId
            transaction.sourceInstitutionId = institution.sourceInstitutionId
            
            return transaction
        })
    }
        
}
