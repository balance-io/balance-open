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
    private let txAmount: Double
    private let fee: Double
    private let balance: Double

    private var currency: Currency {
        return Currency.rawValue(asset)
    }
    
    enum CodingKeys: String, CodingKey {
        case ledgerId
        case referenceId = "refid"
        case timestamp
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
        return referenceId
    }

    var name: String {
        return currency.name
    }

    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }

    var currencyCode: String {
        return currency.code
    }

    var amount: Int {
        return Int(balance)
    }
}

