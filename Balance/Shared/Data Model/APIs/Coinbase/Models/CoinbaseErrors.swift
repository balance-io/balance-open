//
//  CoinbaseErrors.swift
//  Balance
//
//  Created by Joe Blau on 1/19/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

/// https://developers.coinbase.com/api/v2#error-response
internal struct CoinbaseErrors: Decodable {
    var errors: [CoinbaseError]?
}

internal struct CoinbaseError: Decodable {
    var id: String?
    var message: String?
    var url: URL?
}

internal struct CoinbaseOAuthError: Decodable {
    var error: String?
    var errorDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

// MARK: - Extensions

extension CoinbaseError: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

extension CoinbaseOAuthError: LocalizedError {}
