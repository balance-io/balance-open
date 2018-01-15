//
//  Collection+Index.swift
//  BalanceiOS
//
//  Created by Eli Pacheco Hoyos on 1/10/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
