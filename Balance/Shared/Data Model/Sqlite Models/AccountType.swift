//
//  AccountType.swift
//  Bal
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

/// This data is duplicated in the accountTypes database table for use in joins if needed
// TODO: populate that table
enum AccountType: Int, CustomStringConvertible {
    // Main types
    case depository             = 1
    case credit                 = 2
    case loan                   = 3
    case mortgage               = 4
    case brokerage              = 5
    case other                  = 6
    
    // Sub types
    case checking               = 7
    case savings                = 8
    case prepaid                = 9
    case creditCard             = 10
    case lineOfCredit           = 11
    case auto                   = 12
    case home                   = 13
    case installment            = 14
    case cashManagement         = 15
    case ira                    = 16
    case cd                     = 17
    case certificateOfDeposit   = 18
    case mutualFund             = 19
    
    // Other
    case exchange               = 20
    case lending                = 21
    
    init(plaidString: String) {
        switch plaidString {
        case "depository":              self = .depository
        case "credit":                  self = .credit
        case "loan":                    self = .loan
        case "mortgage":                self = .mortgage
        case "brokerage":               self = .brokerage
        case "other":                   self = .other
            
        case "checking":                self = .checking
        case "savings":                 self = .savings
        case "prepaid":                 self = .prepaid
        case "credit card":             self = .creditCard
        case "line of credit":          self = .lineOfCredit
        case "auto":                    self = .auto
        case "home":                    self = .home
        case "installment":             self = .installment
        case "mortgage":                self = .mortgage
        case "cash management":         self = .cashManagement
        case "ira":                     self = .ira
        case "cd":                      self = .cd
        case "certificate of deposit":  self = .certificateOfDeposit
        case "mutual_fund":             self = .mutualFund
            
        case "exchange":                self = .exchange
        case "lending":                 self = .lending
            
        default:                        self = .other
        }
    }
    
    var description: String {
        switch self {
        case .depository:            return "Depository"
        case .credit:                return "Credit"
        case .loan:                  return "Loan"
        case .mortgage:              return "Mortgage"
        case .brokerage:             return "Brokerage"
        case .other:                 return "Other"
            
        case .checking:              return "Checking"
        case .savings:               return "Savings"
        case .prepaid:               return "Prepaid"
        case .creditCard:            return "Credit Card"
        case .lineOfCredit:          return "Line of Credit"
        case .auto:                  return "Auto"
        case .home:                  return "Home"
        case .installment:           return "Installment"
        case .cashManagement:        return "Cash Management"
        case .ira:                   return "IRA"
        case .cd:                    return "CD"
        case .certificateOfDeposit:  return "Certificate of Deposit"
        case .mutualFund:            return "Mutual Fund"
            
        case .exchange:              return "Exchange"
        case .lending:               return "Lending"
        }
    }
}
