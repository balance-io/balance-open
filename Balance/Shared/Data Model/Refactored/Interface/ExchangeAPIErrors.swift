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


//enum APIBasicError: LocalizedError {
//    case bodyNotValidJSON
//    case incorrectLoginCredentials
//    case invalidPermissionCredentials
//    case dataNotPresented
//    case dataWithError(errorDescription: String)
//    case repositoryNotCreated(onExchange: Source)
//
//    var errorDescription: String? {
//        switch self {
//        case .bodyNotValidJSON:
//            return "There was a problem reaching the server."
//        case .incorrectLoginCredentials:
//            return "Invalid login credentials. Make sure you have right API and Secret pair."
//        case .invalidPermissionCredentials:
//            return "Your API key doesn't have enough permisions to perfom this action."
//        case .dataNotPresented:
//            return "Response not contains any data"
//        case .dataWithError(let errorDescription):
//            return "Data fetched from server contains error: \(errorDescription)"
//        case .repositoryNotCreated(let onExchange):
//            return "Repository can't not be created on \(onExchange.description), after pass base validations"
//        }
//    }
//}

