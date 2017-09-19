//
//  KrakenAuthHeaders.swift
//  Balance
//
//  Created by Red Davis on 15/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension KrakenAPIClient
{
    internal struct AuthHeaders
    {
        // Internal
        internal let dictionary: [String : String]
        
        // MARK: Initialization
        
        internal init(credentials: Credentials, requestPath: String, nonce: String, body: String) throws
        {
            let signature = try credentials.generateSignature(nonce: nonce, requestPath: requestPath, body: body)
            
            self.dictionary = [
                "API-Key" : credentials.components.key,
                "API-Sign" : signature
            ]
        }
    }
}
