//
//  BITTREXBalance.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXBalance: Codable {
    
    let currency: String
    let balance: Double
    let available: Double
    let pending: Double
    let cryptoAddress: String?
    let requested: Bool?
    let uuid: String?
    
    enum CodingKeys: String, CodingKey {
        case currency = "Currency"
        case balance = "Balance"
        case available = "Available"
        case pending = "Pending"
        case cryptoAddress = "CryptoAddress"
        case requested = "Requested"
        case uuid = "Uuid"
    }
    
}
