//
//  GDAXAccount.swift
//  BalanceOpen
//
//  Created by Red Davis on 26/07/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension GDAXAPIClient
{
    internal struct Account
    {
        // Internal
        internal let identifier: String
        internal let profileID: String
        internal let availableBalance: Double
        internal let balance: Double
        internal let heldFunds: Double
        internal let currencyCode: String
        
        // MARK: Initialization
        
        internal init(dictionary: [String : Any]) throws
        {
            guard let identifier = dictionary["id"] as? String,
                  let profileID = dictionary["profile_id"] as? String,
                  let currencyCode = dictionary["currency"] as? String,
                  let availableBalanceString = dictionary["available"] as? String,
                  let availableBalance = Double(availableBalanceString),
                  let balanceString = dictionary["balance"] as? String,
                  let balance = Double(balanceString),
                  let heldFundsString = dictionary["hold"] as? String,
                  let heldFunds = Double(heldFundsString) else
            {
                throw GDAXAPIClient.ModelError.invalidJSON(json: dictionary)
            }
            
            self.identifier = identifier
            self.profileID = profileID
            self.availableBalance = availableBalance
            self.balance = balance
            self.heldFunds = heldFunds
            self.currencyCode = currencyCode
        }
    }
}
