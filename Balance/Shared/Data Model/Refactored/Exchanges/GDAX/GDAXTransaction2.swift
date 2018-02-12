//
//  GDAXTransaction2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct GDAXTransaction2: Codable {
    private var accountInstitutionId: Int = 0
    private var accountSourceInstitutionId: String = ""
    private let id: String
    private let createdAt: String
    private let amountString: Double
    private let balanceString: Double
    private let accountType: String
    private let details: GDAXTransactionDetails
    private let currency: String

    private var txAmount: Double {
        return Double(amountString)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "create_at"
        case amountString = "amount"
        case balanceString = "balance"
        case accountType = "type"
        case details
        case currency
    }
    
}

private struct GDAXTransactionDetails: Codable {
    private let orderId: String
    private let tradeId: String
    private let productId: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case tradeId = "trade_id"
        case productId = "product_id"
    }
}

extension GDAXTransaction2: ExchangeTransaction {
    var type: String {
        get {
            return accountType
        }
        set {}
    }
    
    var institutionId: Int {
        get {
            return accountInstitutionId
        }
        set {
            accountInstitutionId = newValue
        }
    }
    
    var source: Source {
        return .gdax
    }
    
    var sourceInstitutionId: String {
        get {
            return accountSourceInstitutionId
        }
        set {
            accountSourceInstitutionId = newValue
        }
    }
    
    var sourceAccountId: String {
        return currency
    }
    
    var sourceTransactionId: String {
        return id
    }
    
    var name: String {
        return Currency.rawValue(currency).name
    }
    
    var date: Date {
        return jsonDateFormatter.date(from: createdAt) ?? Date()
    }
    
    var currencyCode: String {
        return currency
    }
    
    var amount: Int {
        return txAmount.integerFixedCryptoDecimals()
    }
}
