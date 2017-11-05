//
//  KrakenTransaction.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 01/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal extension KrakenAPIClient {
    internal struct Transaction {
        // Internal
        internal let ledgerId: String //key for the other object
        internal let refid: String
        internal let time: Date
        internal let type: TxType
        internal let aclass: Aclass
        internal let asset: Currency
        internal let amount: Double
        internal let fee: Double
        internal let balance: Double
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any], ledgerId: String) throws {
            self.ledgerId = ledgerId
            self.refid = try checkType(dictionary["refid"], name: "refid")
            let timestamp: Double = try checkType(dictionary["time"], name: "timestamp")
            self.time = Date(timeIntervalSince1970: timestamp)
            self.type = TxType.init(rawValue: dictionary["type"] as! String)!
            self.aclass = Aclass.init(rawValue: dictionary["aclass"] as! String)!
            let krakenCurrencyCode: String = try checkType(dictionary["asset"], name: "krakenCurrencyCode")
            self.asset = Currency.rawValue(KrakenAPIClient().transformKrakenCurrencyToCurrencyCode(currency: krakenCurrencyCode))
            let fee: String = try checkType(dictionary["fee"], name: "fee")
            self.fee = Double(fee)!
            let balance: String = try checkType(dictionary["balance"], name: "balance")
            self.balance = Double(balance)!
            let amount: String = try checkType(dictionary["amount"], name: "amount")
            self.amount = Double(amount)!
        }
    }
    
    enum Aclass: String {
        case currency
    }
    
    enum TxType: String {
        case deposit
        case withdrawl
        case trade
        case margin
    }
}
