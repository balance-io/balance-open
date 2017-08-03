//
//  ShapeShiftCoin.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension ShapeShiftAPIClient
{
    internal struct Coin
    {
        // Internal
        internal let name: String
        internal let symbol: String
        internal let imageURL: URL
        internal let isAvailable: Bool
        
        // MARK: Initialization
        
        internal init(name: String, symbol: String, imageURL: URL, isAvailable: Bool)
        {
            self.name = name
            self.symbol = symbol
            self.imageURL = imageURL
            self.isAvailable = isAvailable
        }
        
        internal init(dictionary: [String : Any]) throws
        {
            guard let name = dictionary["name"] as? String,
                  let symbol = dictionary["symbol"] as? String,
                  let imageURLString = dictionary["image"] as? String,
                  let imageURL = URL(string: imageURLString),
                  let status = dictionary["status"] as? String else
            {
                throw ShapeShiftAPIClient.ModelError.invalidJSON(json: dictionary)
            }
            
            let isAvailable = status == "available"
            self.init(name: name, symbol: symbol, imageURL: imageURL, isAvailable: isAvailable)
        }
    }
}
