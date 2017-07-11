//
//  Currency.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente on 06/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

var jsonData = """
{"1CR":{"available":"0.00000000","onOrders\":"0.00000000","btcValue":"0.00000000"}
}
"""
struct PoloniexAccount: Codable {
    let name: String
    let available: Double
    let onOrders: Double
    let btcValue: Double
}

let bitcoin = PoloniexAccount(name: "BTC", available: 0.024, onOrders: 0.00000, btcValue: 0.024)

let encoder = JSONEncoder()
if let encoded = try? encoder.encode(bitcoin) {
    if let json = String(data:encoded, encoding: .utf8) {
        print(json)
    }
}
print("hello")

let decoder = JSONDecoder()

//if let decoded = try? decoder.decode(Currency.self, from:encoded) {
//    print(decoded.name)
//    print(decoded.onOrders)
//}
