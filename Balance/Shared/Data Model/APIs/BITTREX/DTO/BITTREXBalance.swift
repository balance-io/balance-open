//
//  BITTREXBalance.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct BITTREXBalance: Codable {
    
    var currency: String
    var balance: Float
    var available: Float
    var pending: Float
    var cryptoAddress: String
    var requested: Bool
    var uuid: String?
    
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
