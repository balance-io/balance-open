//
//  BITTREXCurrency.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXCurrency: Codable {
 
    let currency: String
    let currencyLong: String
    let minConfirmation: Int
    let txFee: Float
    let isActive: Bool
    let coinType: String
    let baseAddress: String?
    
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
