//
//  Account.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

final class Account {
    let repository: AccountRepository
    
    let accountId: Int
    let institutionId: Int
    let source: Source
    let sourceAccountId: String
    let sourceInstitutionId: String
    let accountType: AccountType
    let accountSubType: AccountType?
    
    let name: String
    
    let currency: String
    let currentBalance: Int
    let availableBalance: Int?
    
    // Last 4 digits of credit card number, if applicable, using String as Plaid uses that format in JSON
    let number: String?
    
    let altCurrency: String?
    let altCurrentBalance: Int?
    let altAvailableBalance: Int?
    
    var transactions = [Transaction]()
    
    required init(result: FMResultSet, repository: ItemRepository = AccountRepository.si) {
        self.repository = repository as! AccountRepository
        
        self.accountId = result.long(forColumnIndex: 0)
        self.institutionId = result.object(forColumnIndex: 1) as! Int
        self.source = Source(rawValue: result.object(forColumnIndex: 2) as! Int)!
        self.sourceAccountId = result.string(forColumnIndex: 3)
        self.sourceInstitutionId = result.string(forColumnIndex: 4)
        self.accountType = AccountType(rawValue: result.object(forColumnIndex: 5) as! Int)!
        let subType = result.object(forColumnIndex: 6) as? Int
        self.accountSubType = subType == nil ? nil : AccountType(rawValue: subType!)
        
        self.name = result.string(forColumnIndex: 7)
        
        self.currency = result.string(forColumnIndex: 8)
        self.currentBalance = result.object(forColumnIndex: 9) as! Int
        self.availableBalance = result.object(forColumnIndex: 10) as? Int
        
        self.number = result.object(forColumnIndex: 11) as? String
        
        self.altCurrency = result.object(forColumnIndex: 12) as? String
        self.altCurrentBalance = result.object(forColumnIndex: 13) as? Int
        self.altAvailableBalance = result.object(forColumnIndex: 14) as? Int
    }
    
    init(accountId: Int, institutionId: Int, source: Source, sourceAccountId: String, sourceInstitutionId: String, accountTypeId: AccountType, accountSubTypeId: AccountType?, name: String, currency: String, currentBalance: Int, availableBalance: Int?, number: String?, altCurrency: String? = nil, altCurrentBalance: Int? = nil, altAvailableBalance: Int? = nil, repository: AccountRepository = AccountRepository.si) {
        self.repository = repository
        
        self.accountId = accountId
        self.institutionId = institutionId
        self.source = source
        self.sourceAccountId = sourceAccountId
        self.sourceInstitutionId = sourceInstitutionId
        self.accountType = accountTypeId
        self.accountSubType = accountSubTypeId
        
        self.name = name
        
        self.currency = currency
        self.currentBalance = currentBalance
        self.availableBalance = availableBalance
        
        self.number = number
        
        self.altCurrency = altCurrency
        self.altCurrentBalance = altCurrentBalance
        self.altAvailableBalance = altAvailableBalance
    }
}

extension Account: Item, Equatable {
    var itemId: Int { return accountId }
    var itemName: String { return displayName }
}

extension Account: CustomStringConvertible {
    var description: String {
        return "\(accountId): \(name)"
    }
}

extension Account {
    var isCreditAccount: Bool {
        // Assume a balance is positive.
        // If there is a bug, it is better for them not to suffer the heart attack of positive balances displaying as negative.
        var isCreditAccount = false
        
        // While credit accounts should be negative
        if accountType == .credit ||
            accountType == .loan ||
            accountType == .mortgage {
            isCreditAccount = true
        }
        
        // Same for the sub types
        if let accountSubType = accountSubType {
            if accountSubType == .checking ||
                accountSubType == .savings ||
                accountSubType == .prepaid ||
                accountSubType == .cashManagement ||
                accountSubType == .ira ||
                accountSubType == .cd ||
                accountSubType == .certificateOfDeposit ||
                accountSubType == .mutualFund {
                isCreditAccount = false
            }
            
            if accountSubType == .creditCard ||
                accountSubType == .lineOfCredit ||
                accountSubType == .auto ||
                accountSubType == .home ||
                accountSubType == .installment {
                isCreditAccount = true
            }
        }
        
        return isCreditAccount
    }
    
    var displayBalance: Int {
        if isCreditAccount {
            // Show negative balance for credit accounts
            return -currentBalance
        } else {
            // For deposit accounts, show the available balance if possible
            return availableBalance ?? currentBalance
        }
    }
    
    var displayName: String {
        switch source {
        case .poloniex, .gdax, .kraken:
            return Currency.rawValue(currency).name
        default:
            return name.capitalizedStringIfAllCaps
        }
    }
    
    var institution: Institution? {
        return InstitutionRepository.si.institution(institutionId: institutionId)
    }
    
    var passwordInvalid: Bool {
        if let institution = self.institution {
            return institution.passwordInvalid
        }
        return false
    }
}
