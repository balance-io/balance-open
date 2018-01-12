//
//  BITTREXCurrency.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXCurrency: Codable {
 
    var currency: String
    var currencyLong: String
    var minConfirmation: Int
    var txFee: Float
    var isActive: Bool
    var coinType: String
    var baseAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case currencyLong = "CurrencyLong"
        case minConfirmation = "MinConfirmation"
        case txFee = "TxFee"
        case isActive = "IsActive"
        case coinType = "CoinType"
        case baseAddress = "BaseAddress"
    }
    
}
