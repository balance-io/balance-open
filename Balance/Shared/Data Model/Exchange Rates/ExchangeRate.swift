//
//  ExchangeRate.swift
//  BalanceServer
//
//  Created by Benjamin Baron on 9/29/17.
//

import Foundation

public struct ExchangeRate { //: Codable {
    let source: ExchangeRateSource
    let from: Currency
    let to: Currency
    let rate: Double
    
//    enum CodingKeys: String, CodingKey {
//        case source
//        case from
//        case to
//        case rate
//    }
//    
//    public init(source: ExchangeRateSource, from: Currency, to: Currency, rate: Double) {
//        self.source = source
//        self.from = from
//        self.to = to
//        self.rate = rate
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        source = try values.decode(ExchangeRateSource.self, forKey: .source)
//        let fromCode = try values.decode(String.self, forKey: .from)
//        from = Currency.rawValue(fromCode)
//        let toCode = try values.decode(String.self, forKey: .to)
//        to = Currency.rawValue(toCode)
//        rate = try values.decode(Double.self, forKey: .rate)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(source, forKey: .source)
//        try container.encode(from.code, forKey: .from)
//        try container.encode(to.code, forKey: .to)
//        try container.encode(rate, forKey: .rate)
//    }
}

public extension Array where Element == ExchangeRate {
    public func contains(from: Currency, to: Currency) -> Bool {
        return self.contains(where: {$0.from == from && $0.to == to})
    }
    
    public func rate(from: Currency, to: Currency) -> Double? {
        if let index = self.index(where: {$0.from == from && $0.to == to}) {
            return self[index].rate
        }
        return nil
    }
}
