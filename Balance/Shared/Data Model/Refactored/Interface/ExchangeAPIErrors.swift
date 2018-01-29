//
//  ExchangeErrors.swift
//  Balance
//
//  Created by Felipe Rolvar on 1/29/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

public enum ExchangeBaseError: Error {
    case internetConnection
    case invalidCredentials(statusCode: Int?)
    case invalidServer(statusCode: Int)
    case other(message: String)
    
    var localizedDescription: String {
        switch self {
        case .internetConnection:
            return "No Internet Connection"
        case .invalidCredentials(_):
            return "Invalid credentials, try again"
        case .invalidServer(_):
            return "We have problems with the server, please try later"
        case .other(let message):
            return "Error: \(message)"
        }
    }
}
