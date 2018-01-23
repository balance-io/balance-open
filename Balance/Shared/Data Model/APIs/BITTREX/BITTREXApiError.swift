//
//  BITTREXApiError.swift
//  BalancemacOS
//
//  Created by Naranjo on 12/12/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

enum BITTREXApiError: LocalizedError {
    case resultRawData
    case invalidCredentials
    case message(errorDescription: String)

    var errorDescription: String? {
        switch self {
        case .resultRawData:
            return "Result object cant not be transformed to a Data object"
        case .invalidCredentials:
            return "Invalid api key or secret"
        case .message(let errorDescription):
            return "Api fails with error: \(errorDescription)"
        }
    }
}
