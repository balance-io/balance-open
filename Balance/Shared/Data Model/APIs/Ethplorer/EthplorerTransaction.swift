//
//  EthplorerTransaction.swift
//  Balance
//
//  Created by Benjamin Baron on 2/1/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerTransaction: Codable {
    let timestamp: Int
    let from: String?
    let to: String?
    let hash: String
    let value: Double
    let input: String
    let success: Bool
}
