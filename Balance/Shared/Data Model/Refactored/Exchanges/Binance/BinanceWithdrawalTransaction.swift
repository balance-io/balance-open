//
//  BinanceWithdrawalTransaction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BinanceWithdrawalTransactionStatus: Int, Codable {
    case emailSent
    case cancelled
    case awaitingApproval
    case rejected
    case processing
    case failure
    case completed
}

struct BinanceWithdrawalList: Codable {
    let withdrawList: [BinanceWithdrawalTransaction]
}

struct BinanceWithdrawalTransaction: Codable {
    
    private let identifier: String
    private let transactionAmount: Double
    private let address: String
    private let asset: String
    private let txId: String
    private let applyTime: Int
    private var currency: Currency {
        return Currency.rawValue(asset)
    }
    
    let status: BinanceWithdrawalTransactionStatus
    var institutionId: Int = 0
    var source: Source = .binance
    var sourceInstitutionId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case transactionAmount = "amount"
        case address
        case asset
        case txId
        case applyTime
        case status
    }
    
}

extension BinanceWithdrawalTransaction: ExchangeTransaction {
    
    var currencyCode: String {
        return currency.code
    }
    
    var type: String {
        get {
            return ExchangeTransactionType.withdrawal.rawValue
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
        let doubleTime = Double(applyTime)
        return Date(timeIntervalSince1970: doubleTime.milisecondsToSeconds())
    }
    
    var amount: Int {
        return -transactionAmount.integerFixedCryptoDecimals()
    }
    
}
