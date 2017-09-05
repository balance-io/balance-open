//
//  AddAccountViewModel.swift
//  BalanceiOS
//
//  Created by Red Davis on 05/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

internal final class AddAccountViewModel
{
    // Internal
    internal var numberOfSources: Int {
        return self.sources.count
    }
    
    // Private
    private let sources: [Source]
    
    // MARK: Initialization
    
    internal required init()
    {
        self.sources = [.coinbase, .gdax, .poloniex]
    }
    
    // MARK: Data
    
    internal func source(at index: Int) -> Source
    {
        return self.sources[index]
    }
}
