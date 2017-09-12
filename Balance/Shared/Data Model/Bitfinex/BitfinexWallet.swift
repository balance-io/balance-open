//
//  BitfinexWallet.swift
//  Balance
//
//  Created by Red Davis on 12/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension BitfinexAPIClient
{
    internal struct Wallet
    {
        // Internal
        internal let walletType: String
        internal let currencyCode: String
        internal let balance: Double
        internal let availableBalance: Double?
        internal let unsettledInterest: Double
        
        // MARK: Initialization
        
        internal init(data: [Any]) throws
        {
            guard data.count == 5 else
            {
                throw BitfinexAPIClient.ModelError.invalidJSON(json: data)
            }
            
            guard let walletType = data[0] as? String,
                  let currencyCode = data[1] as? String,
                  let balance = data[2] as? Double,
                  let unsettledInterest = data[3] as? Double else
            {
                throw BitfinexAPIClient.ModelError.invalidJSON(json: data)
            }
            
            self.walletType = walletType
            self.balance = balance
            self.unsettledInterest = unsettledInterest
            self.currencyCode = currencyCode
            
            if let availableBalanceString = data[4] as? String
            {
                self.availableBalance = Double(availableBalanceString)
            }
            else
            {
                self.availableBalance = nil
            }
        }
    }
}
