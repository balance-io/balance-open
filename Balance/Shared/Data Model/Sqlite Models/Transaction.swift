//
//  Transaction.swift
//  Bal
//
//  Created by Benjamin Baron on 2/1/16.
//   right © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

final class Transaction {
    let repository: TransactionRepository
    
    let transactionId: Int
    let source: Source
    let sourceTransactionId: String
    let accountId: Int?
    let institutionId: Int
    let sourceInstitutionId: String
    
    let name: String
    let currency: String
    let amount: Int
    let date: Date
    
    let categoryId: Int?
    
    var ruleNames: [String]?
    
    required init(result: FMResultSet, repository: ItemRepository = TransactionRepository.si) {
        self.repository = repository as! TransactionRepository
        
        self.transactionId = result.long(forColumnIndex: 0)
        self.source = Source(rawValue: result.long(forColumnIndex: 1))!
        self.sourceTransactionId = result.string(forColumnIndex: 2)
        self.accountId = result.long(forColumnIndex: 3)
        
        self.name = result.string(forColumnIndex: 4)
        
        self.currency = result.string(forColumnIndex: 5)
        self.amount = result.long(forColumnIndex: 6)
        self.date = result.date(forColumnIndex: 7)
        
        self.institutionId = result.object(forColumnIndex: 8) as! Int
        self.sourceInstitutionId = result.string(forColumnIndex: 9)
        self.categoryId = result.object(forColumnIndex: 10) as? Int
    }
    
    init(transactionId: Int, source: Source, sourceTransactionId: String, sourceAccountId: String, accountId: Int, name: String, currency: String, amount: Int, date: Date, categoryID: Int?, institution: Institution, repository: TransactionRepository = TransactionRepository.si) {
        self.repository = repository
        
        self.transactionId = transactionId
        self.source = source
        self.sourceTransactionId = sourceTransactionId
        self.accountId = accountId
        
        self.name = name
        
        self.currency = currency
        self.amount = amount
        self.date = date
        self.categoryId = categoryID
        
        self.sourceInstitutionId = institution.sourceInstitutionId
        self.institutionId = institution.institutionId
    }
}

extension Transaction: Item, Equatable {
    var itemId: Int { return transactionId }
    var itemName: String { return displayName }
}

extension Transaction: Hashable {
    var hashValue: Int {
        return transactionId.hashValue
    }
}

extension Transaction: CustomStringConvertible {
    var description: String {
        return "\(transactionId): \(name)"
    }
}

extension Transaction {
    // Not stored in the DB, in memory only
    var rulesDisplayName: String? {
        if let ruleNames = ruleNames, ruleNames.count > 0 {
            var rulesDisplayName = ""
            var first = true
            for name in ruleNames {
                if !first {
                    rulesDisplayName += "; "
                }
                rulesDisplayName += name
                first = false
            }
            return rulesDisplayName
        }
        return nil
    }
    
    // TODO: Make this non-optional
    fileprivate static var institutionsCache = [Int: Institution]()
    var institution: Institution? {
        if let institution = Transaction.institutionsCache[institutionId] {
            return institution
        } else if let institution = InstitutionRepository.si.institution(institutionId: institutionId) {
            Transaction.institutionsCache[institutionId] = institution
            return institution
        } else {
            return nil
        }
    }
    
    // TODO: Make this non-optional
    var category: Category? {
        if let categoryId = categoryId {
            return CategoryRepository.si.category(categoryId: categoryId)
        } else {
            return nil
        }
    }
    
    // TODO: Make this non-optional
    var account: Account? {
        guard let unwrappedAccountID = self.accountId else {
            return nil
        }
        
        return AccountRepository.si.account(accountId: unwrappedAccountID)
    }
    
    var displayName: String {
        return name.capitalizedStringIfAllCaps
    }
    
    var displayAltAmount: Int? {
        let masterCurrency = defaults.masterCurrency
        if currency == masterCurrency.code {
            return amount
        } else {
            let altAmount: Double = Double(amount) / pow(10.0, Double(Currency.rawValue(currency).decimals))
            return currentExchangeRates.convert(amount: altAmount, from: Currency.rawValue(currency), to: masterCurrency, source: source.exchangeRateSource)?.integerValueWith(decimals: masterCurrency.decimals)
        }
    }
}
