//
//  EthplorerTransaction2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/8/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerTransaction2: Codable {
    private var txType: String = ""
    private var txInstitutionId: Int = 0
    private var txSourceInstitutionId: String = ""
    private let timestamp: Int
    private let from: String?
    private let to: String?
    private let hash: String
    private let value: Double
    private let input: String
    private let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case from
        case to
        case hash
        case value
        case input
        case success
    }
}

extension EthplorerTransaction2: ExchangeTransaction {
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
        return .ethplorer
    }
    
    var sourceInstitutionId: String {
        get {
            return txSourceInstitutionId
        }
        set {
            txSourceInstitutionId = newValue
        }
    }
    
    var sourceAccountId: String {
        return Currency.eth.code
    }
    
    var sourceTransactionId: String {
        return hash
    }
    
    var name: String {
        return hash
    }
    
    var date: Date {
        return Date(timeIntervalSince1970: Double(timestamp))
    }
    
    var currencyCode: String {
        return Currency.eth.code
    }
    
    var amount: Int {
        return value.integerFixedCryptoDecimals()
    }
}
