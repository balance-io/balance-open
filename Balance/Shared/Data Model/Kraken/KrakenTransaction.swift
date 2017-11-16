//
//  KrakenTransaction.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 01/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal extension KrakenAPIClient {
    struct Transaction {
        // Internal
        let ledgerId: String //key for the other object
        let refid: String
        let time: Date
        let type: TxType
        let aclass: Aclass
        let asset: Currency
        let amount: Double
        let fee: Double
        let balance: Double
        
        // MARK: Initialization
        
        init(dictionary: [String : Any], ledgerId: String) throws {
            self.ledgerId = ledgerId
            self.refid = try checkType(dictionary["refid"], name: "refid")
            let timestamp: Double = try checkType(dictionary["time"], name: "timestamp")
            self.time = Date(timeIntervalSince1970: timestamp)
            let typeString: String = try checkType(dictionary["type"], name: "typeString")
            self.type = try checkType(TxType(rawValue: typeString), name: "type")
            let aclassString: String = try checkType(dictionary["aclass"], name: "aclassString")
            self.aclass = try checkType(Aclass(rawValue: aclassString), name: "aclass")
            let krakenCurrencyCode: String = try checkType(dictionary["asset"], name: "krakenCurrencyCode")
            self.asset = Currency.rawValue(KrakenAPIClient.transformKrakenCurrencyToCurrencyCode(currency: krakenCurrencyCode))
            let fee: String = try checkType(dictionary["fee"], name: "feeString")
            self.fee = try checkType(Double(fee), name: "fee")
            let balance: String = try checkType(dictionary["balance"], name: "balanceString")
            self.balance = try checkType(Double(balance), name: "balance")
            let amount: String = try checkType(dictionary["amount"], name: "amountString")
            self.amount = try checkType(Double(amount), name: "amount")
        }
    }
    
    enum Aclass: String {
        case currency
    }
    
    enum TxType: String {
        case deposit
        case withdrawal
        case trade
        case margin
    }
}
