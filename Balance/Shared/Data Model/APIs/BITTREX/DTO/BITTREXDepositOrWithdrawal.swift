//
//  BITTREXDepositWithdrawal.swift
//  Balance
//
//  Created by Benjamin Baron on 1/18/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXDepositOrWithdrawal: Codable {

    let paymentUuid: String
    let currency: String
    let amount: Double
    let address: String
    let opened: String
    let authorized: Bool
    let pendingPayment: Bool
    let txCost: Double
    let txId: String?
    let canceled: Bool
    let invalidAddress: Bool
    
    enum CodingKeys: String, CodingKey {
        case paymentUuid = "PaymentUuid"
        case currency = "Currency"
        case amount = "Amount"
        case address = "Address"
        case opened = "Opened"
        case authorized = "Authorized"
        case pendingPayment = "PendingPayment"
        case txCost = "TxCost"
        case txId = "TxId"
        case canceled = "Canceled"
        case invalidAddress = "InvalidAddress"
    }
    
}

fileprivate var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter
}

extension BITTREXDepositOrWithdrawal {
    var date: Date? {
        return dateFormatter.date(from: opened)
    }
}
