//
//  NumberUtils.swift
//  BalanceOpen
//
//  Created by Raimon Lapuente on 28/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct NumberUtils {
    static var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = .decimal
        formatter.allowsFloats = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
