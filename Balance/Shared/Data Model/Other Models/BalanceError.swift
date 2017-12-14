//
//  BalanceError.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 9/7/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BalanceError: Int, LocalizedError {
    case success             = 0
    case invalidReceipt      = 1
    case subscriptionExpired = 2
    case networkError        = 3
    case databaseError       = 4
    case unknownError        = 5
    case accountLimitReached = 6
    case plaidApiError       = 7
    case invalidInputData    = 8
    case emailSendError      = 9
    case jsonDecoding        = 10
    case jsonEncoding        = 11
    case noData              = 12
    case noReceipt           = 13
    case unexpectedData      = 14
    
    var errorDescription: String? {
        switch self {
        case .success:             return "Success"
        case .invalidReceipt:      return "Invalid receipt"
        case .subscriptionExpired: return "Subscription expired"
        case .networkError:        return "Network error"
        case .databaseError:       return "Database error"
        case .unknownError:        return "Unkown error"
        case .accountLimitReached: return "Account limit reached"
        case .plaidApiError:       return "Plaid API error"
        case .invalidInputData:    return "Invalid input data"
        case .emailSendError:      return "Error sending email"
        case .jsonDecoding:        return "JSON decoding error"
        case .jsonEncoding:        return "JSON encoding error"
        case .noData:              return "No data"
        case .noReceipt:           return "No app store receipt"
        case .unexpectedData:      return "Unexpected data"
        }
    }
}
