//
//  ShapeShiftErrors.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


// MARK: Model error

internal extension ShapeShiftAPIClient
{
    internal enum ModelError: Error
    {
        case invalidJSON(json: [String : Any])
    }
}


// MARK: API Error

internal extension ShapeShiftAPIClient
{
    internal enum APIError: Error
    {
        case invalidJSON
        case response(httpResponse: HTTPURLResponse, data: Data?)
    }
}
