//
//  BITTREXDepositWithdrawal.swift
//  Balance
//
//  Created by Benjamin Baron on 1/18/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXWithdrawal: Codable {

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

extension BITTREXWithdrawal {
    var date: Date? {
        return jsonWithMillisecondsDateFormatter.date(from: opened)
    }
}
