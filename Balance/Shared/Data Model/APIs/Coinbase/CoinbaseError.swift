//
//  CoinbaseError.swift
//  Balance
//
//  Created by Benjamin Baron on 9/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

// NOTE: According to the Coinbase docs, all token requests (i.e. requestToken and refreshToken) always return
//       an invalidRequest with a description. These errors are only relevant for other Coinbase API calls.
//       https://developers.coinbase.com/api/v2#error-response
enum CoinbaseError: String, LocalizedError {
    case twoFactorRequired       = "two_factor_required"
    case paramRequired           = "param_required"
    case validationError         = "validation_error"
    case invalidRequest          = "invalid_request"
    case personalDetailsRequired = "personal_details_required"
    case unverifiedEmail         = "unverified_email"
    case authenticationError     = "authentication_error"
    case invalidToken            = "invalid_token"
    case revokedToken            = "revoked_token"
    case expiredToken            = "expired_token"
    case invalidScope            = "invalid_scope"
    case rateLimitExceeded       = "rate_limit_exceeded"
    
    // NOTE: Check to see if these actually hit since they use 404 and 500 error codes, we might just get a URLSession error
    case notFound                = "not_found"
    case internalServerError     = "internal_server_error"
    
    var errorDescription: String? {
        switch self {
        case .twoFactorRequired: return ""
        default: return ""
        }
    }
}
