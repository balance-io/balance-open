//
//  Currency.swift
//  BalanceForBlockchain
//
//  Created by Benjamin Baron on 6/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum Currency {
    enum Traditional: String {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case cad = "CAD"
    }
    case crypto(shortName: String)
    case common(traditional: Traditional)
    
    static func rawValue(shortName: String) -> Currency {
        switch shortName {
            case "USD": return .common(traditional:.usd)
            case "EUR": return .common(traditional:.eur)
            case "GBP": return .common(traditional:.gbp)
            case "CAD": return .common(traditional:.cad)
            default: return .crypto(shortName: shortName)
        }
    }
    
    var decimals: Int {
        switch self {
            case .common(traditional:.usd), .common(traditional:.eur), .common(traditional:.gbp): return 2
            default: return 8
        }
    }
    
    var symbol: String {
        switch self {
            case .common(traditional:.usd): return "$"
            case .common(traditional:.eur): return "€"
            case .common(traditional:.gbp): return "£"
            case .common(traditional:.cad): return "C$"
            case .crypto(let val): return val + " "
        }
    }
    
    var name: String {
        switch self {
            case .common(traditional:.usd): return "USD"
            case .common(traditional:.eur): return "EUR"
            case .common(traditional:.gbp): return "GBP"
            case .common(traditional:.cad): return "CAD"
            case .crypto(let val): return val
        }
    }
}
