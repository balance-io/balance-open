//
//  GDAXTransaction.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 07/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension GDAXAPIClient {
    
//    "id": "100",
//    "created_at": "2014-11-07T08:19:27.028459Z",
//    "amount": "0.001",
//    "balance": "239.669",
//    "type": "fee",
//    "details": {
//    "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
//    "trade_id": "74",
//    "product_id": "BTC-USD"
//    }
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier:"en_US_POSIX")        
        return formatter
    }()
    
    struct Transaction {
        let id: String
        let createdAt: Date
        let amount: Double
        let balance: Double
        let type: EntryType?
        let productId: String?
        let transferId: String?
        let currencyCode: String
        
        init(dictionary: [String : Any], currencyCode: String) throws {
            let id: Int = try checkType(dictionary["id"], name: "id")
            self.id = String(id)
            let createdAt: String = try checkType(dictionary["created_at"], name: "createdAt")
            self.createdAt = dateFormatter.date(from:createdAt)!
            if  let detail = dictionary["detail"] as? [String:Any] {
                self.type = EntryType.init(rawValue: detail["transfer_type"] as! String)
                self.transferId = detail["transfer_id"] as? String
                self.productId = detail["product_id"] as? String
            } else {
                self.type = nil
                self.transferId = nil
                self.productId = nil
            }
            let balanceString: String = try checkType(dictionary["balance"], name: "balance")
            let balanceDouble = Double(balanceString)
            guard let balance = balanceDouble else {
                throw "balance was not a Double"
            }
            self.balance = balance
            
            let amountString: String = try checkType(dictionary["amount"], name: "amount")
            let amountDouble = Double(amountString)
            guard let amount = amountDouble else {
                throw "amount was not a Double"
            }
            self.amount = Double(amount)
            self.currencyCode = currencyCode
        }
    }
    
    enum EntryType: String {
        case fee
        case transfer
        case match
        case rebate
    }
}
