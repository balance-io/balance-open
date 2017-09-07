//
//  ApplicationConfiguration.swift
//  BalanceiOS
//
//  Created by Red Davis on 07/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation


internal enum ApplicationConfiguration
{
    static let userDefaults = UserDefaults.standard //TODO: UserDefaults(suiteName: "balance.group")
    static let userPreferences = UserPreferences(identifier: "main", userDefaults: ApplicationConfiguration.userDefaults)
}
