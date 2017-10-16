//
//  AddAccountViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal final class NewAccountListViewModel
{
    // Internal
    internal var numberOfSources: Int {
        return self.sources.count
    }
    
    // Private
    private let sources: [Source] = [.coinbase, .gdax, .poloniex, .bitfinex, .kraken, .ethplorer]

    // MARK: Initialization
    
    internal required init()
    {
        
    }
    
    // MARK: Data
    
    internal func source(at index: Int) -> Source
    {
        return self.sources[index]
    }
}
