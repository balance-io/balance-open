//
//  CoinbaseWarnings.swift
//  Balance
//
//  Created by Joe Blau on 1/19/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

/// https://developers.coinbase.com/api/v2#warnings
internal struct CoinbaseWarnings: Decodable {
    var warnings: [CoinbaseWarning]?
}

internal struct CoinbaseWarning: Decodable {
    var id: String?
    var message: String?
    var url: URL?
}

// MARK: - Extensions

extension CoinbaseWarning: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
