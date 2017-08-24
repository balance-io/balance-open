//
//  CoinbaseWalletAddress.swift
//  BalanceOpen
//
//  Created by Red Davis on 24/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal struct CoinbaseWalletAddress
{
    // Internal
    internal let identifier: String
    internal let address: String
    internal let name: String
    
    // MARK: Initialization
    
    internal init(dictionary: [String : Any]) throws
    {
        guard let identifier = dictionary["id"] as? String,
              let address = dictionary["address"] as? String,
              let name = dictionary["name"] as? String else
        {
            throw "Invalid JSON"
        }
        
        self.identifier = identifier
        self.address = address
        self.name = name
    }
}
