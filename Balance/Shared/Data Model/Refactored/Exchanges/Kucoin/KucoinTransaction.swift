//
//  KucoinTransaction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/14/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum KucoinTransactionType: Equatable {
    case deposit
    case withdrawal
    case unknown(type: String)
    
    init(type: String) {
        switch type {
        case "DEPOSIT":
            self = .deposit
        case "WITHDRAW":
            self = .withdrawal
        default:
            self = .unknown(type: type)
        }
    }
    
    static func==(left: KucoinTransactionType, right: KucoinTransactionType) -> Bool {
        switch (left, right) {
        case (.deposit, .deposit):
            return true
        case (.withdrawal, .withdrawal):
            return true
        case (.unknown(let leftType), .unknown(let rightType)):
            return leftType == rightType
        default:
            return false
        }
    }
    
}

enum KucoinTransactionStatus: Equatable {
    case success
    case cancel
    case unknown(status: String)
    
    private enum CodingKeys: String, CodingKey {
        case success = "SUCCESS"
        case cancel = "CANCEL"
    }
    
    init(status: String) {
        switch status {
        case "SUCCESS":
            self = .success
        case "CANCEL":
            self = .cancel
        default:
            self = .unknown(status: status)
        }
    }
    
    static func==(left: KucoinTransactionStatus, right: KucoinTransactionStatus) -> Bool {
        switch (left, right) {
        case (.success, .success):
            return true
        case (.cancel, .cancel):
            return true
        case (.unknown(let leftStatus), .unknown(let rightStatus)):
            return leftStatus == rightStatus
        default:
            return false
        }
    }
    
}

struct KucoinTransactions: Decodable {
    private let data: KucoinTransactionsInformation
    
    var transactions: [KucoinTransaction] {
        return data.datas
    }
}

fileprivate struct KucoinTransactionsInformation: Decodable {
    let datas: [KucoinTransaction]
}

struct KucoinTransaction: Decodable {
    
    private let fee: Double
    private let oid: String
    private let transactionAmount: Double
    private let address: String
    private let coinType: String
    private let createdAt: Double
    private let updatedAt: Double
    
    private let transactionType: String
    private let transactionStatus: String
    
    private var currency: Currency {
        return Currency.rawValue(coinType)
    }
    
    var status: KucoinTransactionStatus {
        return KucoinTransactionStatus(status: transactionStatus)
    }
    
    var institutionId: Int = -1
    var source: Source = .kucoin
    var sourceInstitutionId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case fee
        case oid
        case transactionType = "type"
        case transactionAmount = "amount"
        case transactionStatus = "status"
        case address
        case coinType
        case createdAt
        case updatedAt
    }
    
}

extension KucoinTransaction: ExchangeTransaction {

    var currencyCode: String {
        return currency.code
    }
    
    var type: String {
        get {
            let transactionType = KucoinTransactionType(type: self.transactionType)
            switch transactionType {
            case .deposit:
                return ExchangeTransactionType.deposit.rawValue
            case .withdrawal:
                return ExchangeTransactionType.withdrawal.rawValue
            default:
                print("Invalid type for kucoin transaction")
                return ""
            }
        }
        set {
            
        }
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var sourceTransactionId: String {
        return oid
    }
    
    var name: String {
        return oid
    }
   
    var date: Date {
        return Date(timeIntervalSince1970: createdAt.milisecondsToSeconds())
    }
    
    var amount: Int {
        let transactionType = KucoinTransactionType(type: self.transactionType)
        if case .unknown(_) = transactionType {
            return 0
        }
        
        let realAmount = transactionAmount.integerFixedCryptoDecimals()
        
        return transactionType == .withdrawal && realAmount > 0 ? -realAmount : realAmount
    }
    
}

