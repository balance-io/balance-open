//
//  BITTREXTransaction2.swift
//  Balance
//
//  Created by Felipe Rolvar on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXTransaction2 {
    private var txType: String = ""
    private var txInstitutionId: Int = 0
    private var txSourceInstitutionId: String = ""
    private let txId: String
    private let paymentUuid: String
    private let currency: String
    private let txAmount: Double
    private let address: String
    private let createdAt: String
    private let authorized: Bool
    private let pendingPayment: Bool
    private let txCost: Double
    private let canceled: Bool
    private let invalidAddress: Bool
    
    enum CodingKeys: String, CodingKey {
        case paymentUuid = "PaymentUuid"
        case currency = "Currency"
        case txAmount = "Amount"
        case address = "Address"
        case createAt = "Opened"
        case authorized = "Authorized"
        case pendingPayment = "PendingPayment"
        case txCost = "txCost"
        case txId = "TxId"
        case canceled = "Canceled"
        case invalidAddress = "InvalidAddress"
    }
}

extension BITTREXTransaction2: ExchangeTransaction {
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
        return .bittrex
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
        return currencyCode
    }
    
    var sourceTransactionId: String {
        return paymentUuid
    }
    
    var name: String {
        return paymentUuid
    }
    
    var date: Date {
        return jsonDateFormatter.date(from: createdAt) ?? Date()
    }
    
    var currencyCode: String {
        return currency == "BCC" ? "BCH" : currency
    }
    
    var amount: Int {
        return txAmount.integerFixedCryptoDecimals()
    }
}
