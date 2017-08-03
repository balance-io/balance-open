//
//  HTTPURLResponse.swift
//  BalanceOpen
//
//  Created by Red Davis on 02/08/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal extension HTTPURLResponse
{
    internal var isSuccess: Bool {
        return 200...299 ~= self.statusCode
    }
}
