//
//  BalanceError.swift
//  Bal
//
//  Created by Benjamin Baron on 7/14/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BalanceError: Int, Error {
    case noReceipt
    case jsonSerialization
    case jsonParsing
    case noData
    case plaidApiError
    
    var message: String {
        switch self {
        case .noReceipt:
            return "No App Store receipt found. You may need to re-download Balance from the App Store."
        case .jsonSerialization:
            return "We could not serialize a json dictionary. This should never happen."
        case .jsonParsing:
            return "We tried to parse a JSON response and didn't get the data we expected."
        case .noData:
            return "We tried to connect to an API and we got no data back, but there was no network error. Please try again soon."
        case .plaidApiError:
            return "We tried to get data from Plaid, but there was an error"
        }
    }
}
