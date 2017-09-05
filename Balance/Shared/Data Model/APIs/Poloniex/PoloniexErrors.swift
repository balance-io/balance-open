//
//  PoloniexErrors.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal extension PoloniexApi
{
    internal enum CredentialsError: Error
    {
        case invalidCredentials(message: String)
        case bodyNotValidJSON
        case invalidJSON(json: [String : Any])
        case incorrectLoginCredentials(message: String)
    }
}
