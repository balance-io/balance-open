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
    let accountId: Int
    let institutionId: Int
    let sourceInstitutionId: String
    
    let name: String
    
    let currency: String
    let amount: Int
    
    let altCurrency: String?
    let altAmount: Int?
    
    let date: Date
    let pending: Bool
    
    let address: String?
    let city: String?
    let state: String?
    let zip: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    
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
        self.altCurrency = result.string(forColumnIndex: 7)
        self.altAmount = result.object(forColumnIndex: 8) as? Int
        
        self.date = result.date(forColumnIndex: 9)
        self.pending = result.bool(forColumnIndex: 10)
        
        self.address = result.string(forColumnIndex: 11)
        self.city = result.string(forColumnIndex: 12)
        self.state = result.string(forColumnIndex: 13)
        self.zip = result.string(forColumnIndex: 14)
        self.latitude = result.object(forColumnIndex: 15) as? Double
        self.longitude = result.object(forColumnIndex: 16) as? Double
        self.phone = result.string(forColumnIndex: 17)
        
        self.categoryId = result.object(forColumnIndex: 18) as? Int
        
        self.sourceInstitutionId = result.string(forColumnIndex: 19)
        self.institutionId = result.object(forColumnIndex: 20) as! Int
    }
    
    init(transactionId: Int, source: Source, sourceTransactionId: String, sourceAccountId: String, accountId: Int, name: String, currency: String, amount: Int, altCurrency: String?, altAmount: Int?, date: Date, pending: Bool, address: String?, city: String?, state: String?, zip: String?, latitude: Double?, longitude: Double?, phone: String?, categoryId: Int?, institution: Institution, repository: TransactionRepository = TransactionRepository.si) {
        self.repository = repository
        
        self.transactionId = transactionId
        self.source = source
        self.sourceTransactionId = sourceTransactionId
        self.accountId = accountId
        
        self.name = name
        
        self.currency = currency
        self.amount = amount
        self.altCurrency = altCurrency
        self.altAmount = altAmount
        self.date = date
        self.pending = pending
        
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        
        self.categoryId = categoryId
        
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
        return AccountRepository.si.account(accountId: accountId)
    }
    
    var hasLocation: Bool {
        return address != nil && latitude != nil && longitude != nil
    }
    
    var displayName: String {
        return name.capitalizedStringIfAllCaps
    }
}
