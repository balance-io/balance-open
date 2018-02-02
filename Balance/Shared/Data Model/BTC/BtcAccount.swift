//
//  BtcAccount.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 30/01/2018.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

//Info to be found on https://blockchain.info/api/blockchain_api

struct BtcAccount {
    let hash160: String
    let address: String
    
    let nTx: Int
    let totalReceived: Int
    let totalSent: Int
    let finalBalance: Int
    //part of next iteration
//    let nUnredeemed: Int?
//    let txs: [String]?
    
    let type: AccountType
    let currency: Currency
    
    init(dictionary: [String: Any], type: AccountType) throws {

        self.hash160 = try checkType(dictionary["hash160"], name: "hash160")
        self.address = try checkType(dictionary["address"], name: "address")
        
        self.nTx = try checkType(dictionary["n_tx"], name: "nTx")

        self.totalReceived = try checkType(dictionary["total_received"], name: "totalReceived")
        self.totalSent = try checkType(dictionary["total_sent"], name: "totalSent")
        self.finalBalance = try checkType(dictionary["final_balance"], name: "finalBalance")
//        self.txs = try checkType(dictionary["txs"], name: "txs")
     
        self.type = type
        self.currency = .btc
    }
}
