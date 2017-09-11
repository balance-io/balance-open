//
//  Server.swift
//  BalanceOpen
//
//  Created by Red Davis on 27/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension GDAXAPIClient
{
    internal enum Server
    {
        case sandbox, production
        
        // MARK: URL
        
        internal func url() -> URL
        {
            switch self
            {
            case .production:
                return URL(string: "https://api.gdax.com")!
            case .sandbox:
                return URL(string: "https://api-public.sandbox.gdax.com")!
            }
        }
    }
}
