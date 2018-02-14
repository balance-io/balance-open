//
//  BinanceDepositTransaction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BinanceDepositTransactionStatus: Int, Codable {
    case pending
    case success
}

struct BinanceDepositList: Codable {
    let depositList: [BinanceDepositTransaction]
}

struct BinanceDepositTransaction: Codable {
    
    private let insertTime: Int
    private let transactionAmount: Double
    private let asset: String
    private let address: String
    private let txId: String
    private var currency: Currency {
        return Currency.rawValue(asset)
    }
    
    let status: BinanceDepositTransactionStatus
    var institutionId: Int = -1
    var source: Source = .binance
    var sourceInstitutionId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case insertTime
        case transactionAmount = "amount"
        case address
        case asset
        case txId
        case status
    }
    
}

extension BinanceDepositTransaction: ExchangeTransaction {
    
    var currencyCode: String {
        return currency.code
    }
    
    var type: String {
        get {
            return ExchangeTransactionType.deposit.rawValue
        }
        set {
            
        }
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var sourceTransactionId: String {
        return txId
    }
    
    var name: String {
        return txId
    }
    
    var date: Date {
        let doubleTime = Double(insertTime)
        return Date(timeIntervalSince1970: doubleTime.milisecondsToSeconds())
    }
    
    var amount: Int {
        return transactionAmount.integerFixedCryptoDecimals()
    }
    
}
