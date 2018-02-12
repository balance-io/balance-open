//
//  HitBTCTransaction.swift
//  Balance
//
//  Created by Eli Pacheco Hoyos on 2/12/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum HitBTCTransactionStatus: String, Codable {
    case pending
    case failed
    case success
}

enum HitBTCTransactionType: String, Codable {
    case payout
    case payin
    case deposit
    case withdraw
    case bankToExchange
    case exchangeToBank
    
    var exchangeType: ExchangeTransactionType {
        switch self {
        case .payout, .withdraw, .exchangeToBank:
            return .withdrawal
        case .payin, .deposit, .bankToExchange:
            return .deposit
        }
    }
}

@available(OSX 10.12, *)
fileprivate let isoFormatter = ISO8601DateFormatter()

fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    return dateFormatter
}()


struct HitBTCTransaction {
    
    private let identifier: String
    private let transactionAmount: Double
    private let address: String
    private let fee: String
    private let networkFee: String
    private let hash: String
    private let status: HitBTCTransactionStatus
    private let transactionType: HitBTCTransactionType
    private let createdAt: String
    
    private var currency: Currency {
        return Currency.rawValue(currencyCode)
    }
    
    let currencyCode: String
    let source: Source = .hitbtc
    var institutionId: Int = 0
    var sourceInstitutionId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case transactionAmount = "amount"
        case address
        case fee
        case networkFee
        case hash
        case status
        case transactionType = "type"
        case currencyCode = "currency"
        case createdAt
    }
}

extension HitBTCTransaction: ExchangeTransaction {

    var type: String {
        get {
            return transactionType.exchangeType.rawValue
        }
        set {
            
        }
    }
    
    var sourceAccountId: String {
        return currency.code
    }
    
    var sourceTransactionId: String {
        return identifier
    }
    
    var name: String {
        return identifier
    }
    
    var date: Date {
        let trimmedIsoString = createdAt.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        if #available(OSX 10.12, *) {
            guard let date = isoFormatter.date(from: trimmedIsoString) else {
                print("Invalid time from response, can not being transformed to date with ISOFormatter")
                return Date()
            }
            
            return date
        } else {
            guard let date = dateFormatter.date(from: trimmedIsoString) else {
                print("Invalid time from response, can not being transformed to date with DateFormatter")
                return Date()
            }
            
            return date
        }
    }
    
    var amount: Int {
        return transactionAmount.integerFixedCryptoDecimals()
    }
    
}
