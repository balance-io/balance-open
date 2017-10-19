//
//  Currency.swift
//  Balance
//
//  Created by Red Davis on 19/10/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension Currency {
    internal static let masterCurrencies: [Currency] = {
        return Currency.masterFiatCurrencies + Currency.masterCryptoCurrencies
    }()
    
    internal static let masterFiatCurrencies: [Currency] = {
        return [
            Currency.fiat(enum: .usd),
            Currency.fiat(enum: .aud),
            Currency.fiat(enum: .cad),
            Currency.fiat(enum: .eur),
            Currency.fiat(enum: .hkd),
            Currency.fiat(enum: .dkk),
            Currency.fiat(enum: .jpy),
            Currency.fiat(enum: .cny),
            Currency.fiat(enum: .gbp)
        ]
    }()
    
    internal static let masterCryptoCurrencies: [Currency] = {
        return [
            Currency.crypto(enum: .btc),
            Currency.crypto(enum: .eth),
            Currency.crypto(enum: .ltc)
        ]
    }()
}
