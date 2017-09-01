//
//  ShapeShiftMarketInformation.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension ShapeShiftAPIClient
{
    internal struct MarketInformation
    {
        internal let coinPair: CoinPair
        internal let rate: Double
        internal let maximumDepositLimit: Double
        internal let minimumDepositLimit: Double
        internal let minerFee: Double
        
        // MARK: Initialization
        
        internal init(coinPair: CoinPair, dictionary: [String : Any]) throws
        {
            guard let rate = dictionary["rate"] as? Double,
                  let limit = dictionary["maxLimit"] as? Double,
                  let minimumLimit = dictionary["minimum"] as? Double,
                  let minerFee = dictionary["minerFee"] as? Double else
            {
                throw ModelError.invalidJSON(json: dictionary)
            }
            
            self.coinPair = coinPair
            self.rate = rate
            self.maximumDepositLimit = limit
            self.minimumDepositLimit = minimumLimit
            self.minerFee = minerFee
        }
    }
}
