//
//  AuthHeaders.swift
//  BalanceOpen
//
//  Created by Red Davis on 27/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension GDAXAPIClient
{
    internal struct AuthHeaders
    {
        // Internal
        internal let dictionary: [String : String]
        
        // MARK: Initialization
        
        internal init(credentials: Credentials, requestPath: String, method: String, body: Data?) throws
        {
            let nowDate = Date()
            let signature = try credentials.generateSignature(timestamp: nowDate, requestPath: requestPath, body: body, method: method)
            
            self.dictionary = [
                "CB-ACCESS-KEY" : credentials.key,
                "CB-ACCESS-SIGN" : signature,
                "CB-ACCESS-TIMESTAMP" : "\(nowDate.timeIntervalSince1970)",
                "CB-ACCESS-PASSPHRASE" : credentials.passphrase
            ]
        }
    }
}
