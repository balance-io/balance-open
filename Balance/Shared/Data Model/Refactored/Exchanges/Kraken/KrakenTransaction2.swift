//
//  KrakenTransaction2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/7/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct KrakenTransaction2: Codable {
    private var txInstitutionId: Int = 0
    private var txSourceInstitutionId: String = ""
    private let ledgerId: String
    private let referenceId: String
    private let timestamp: Double
    private var txType: String
    private let asset: String
    private let assetClass: String
    private let txAmount: String
    private let fee: String
    private let balance: String

    private var currency: Currency {
        var currencyCode = asset
        if asset.count == 4 && (asset.hasPrefix("Z") || asset.hasPrefix("X")) {
            currencyCode = asset.substring(from: 1)
        }
        return Currency.rawValue(currencyCode)
    }
    
    enum CodingKeys: String, CodingKey {
        case ledgerId
        case referenceId = "refid"
        case timestamp = "time"
        case txType = "type"
        case asset
        case assetClass = "aclass"
        case txAmount = "amount"
        case fee
        case balance
    }
}

// MARK: Protocol

extension KrakenTransaction2: ExchangeTransaction {
    var type: String {
        get {
            return txType
        }
        set {
            txType = newValue
        }
    }

    var institutionId: Int {
        get {
            return txInstitutionId
        }
        set {
            txInstitutionId = newValue
        }
    }

    var source: Source {
        return .kraken
    }

    var sourceInstitutionId: String {
        get {
            return txSourceInstitutionId
        }
        set {
            txSourceInstitutionId = ""
        }
    }

    var sourceAccountId: String {
        return currency.code
    }

    var sourceTransactionId: String {
        return "\(ledgerId)\(amount)\(date)"
    }

    var name: String {
        return sourceTransactionId
    }

    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }

    var currencyCode: String {
        return currency.code
    }

    var amount: Int {
        return Double(txAmount)?.integerValueWith(decimals: currency.decimals) ?? 0
    }
}

