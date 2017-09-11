//
//  TabViewModel.swift
//  Bal
//
//  Created by Benjamin Baron on 5/22/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

protocol TabViewModel {
    func reloadData()
    func numberOfSections() -> Int
    func numberOfRows(inSection section: Int) -> Int
}
