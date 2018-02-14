//
//  KucoinTransaction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/14/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum KucoinTransactionType: Decodable {
    case deposit
    case withdrawal
    case unknown
    
    private enum CodingKeys: String, CodingKey {
        case deposit = "DEPOSIT"
        case withdrawal = "WITHDRAWAL"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if (try? values.decode(String.self, forKey: .deposit)) != nil {
            self = .deposit
        }
        
        if (try? values.decode(String.self, forKey: .withdrawal)) != nil {
            self = .withdrawal
        }
        
        self = .unknown
    }
    
}

enum KucoinTransactionStatus: Decodable {
    case success
    case cancel
    case unknown
    
    private enum CodingKeys: String, CodingKey {
        case success = "SUCCESS"
        case cancel = "CANCEL"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if (try? values.decode(String.self, forKey: .success)) != nil {
            self = .success
        }
        
        if (try? values.decode(String.self, forKey: .cancel)) != nil {
            self = .cancel
        }
        
        self = .unknown
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
    private let transactionType: KucoinTransactionType
    private let transactionAmount: Double
    private let address: String
    private let coinType: String
    private let createdAt: Double
    private let updatedAt: Double
    
    private var currency: Currency {
        return Currency.rawValue(coinType)
    }
    
    let status: KucoinTransactionStatus
    var institutionId: Int = -1
    var source: Source = .kucoin
    var sourceInstitutionId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case fee
        case oid
        case transactionType = "type"
        case transactionAmount = "amount"
        case status
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
        guard transactionType == .unknown else {
            return 0
        }
        
        let realAmount = transactionAmount.integerFixedCryptoDecimals()
        
        return transactionType == .withdrawal && realAmount > 0 ? -realAmount : realAmount
    }
    
}

