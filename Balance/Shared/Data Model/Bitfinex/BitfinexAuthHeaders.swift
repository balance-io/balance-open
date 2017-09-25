//
//  BitfinexAuthHeaders.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension BitfinexAPIClient
{
    internal struct AuthHeaders
    {
        // Internal
        internal let dictionary: [String : String]
        
        // MARK: Initialization
        
        internal init(credentials: Credentials, requestPath: String, body: Data?) throws
        {
            let nowDate = Date()
            let signature = try credentials.generateSignature(date: nowDate, requestPath: requestPath, body: body)
            
            self.dictionary = [
                "bfx-apikey" : credentials.components.key,
                "bfx-signature" : signature,
                "bfx-nonce" : "\(nowDate.timeIntervalSince1970)"
            ]
        }
    }
}
