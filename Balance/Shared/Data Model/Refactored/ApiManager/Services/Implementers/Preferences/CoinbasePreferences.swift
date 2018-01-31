//
//  CoinbasePreferences.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/31/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import Foundation

class CoinbasePreferences {
    
    private struct PreferencesKeys {
        static let tokenExpireDate = "tokenExpireDateKey"
        static let apiScope = "Institution.apiScopeKey"
    }
    
    static var tokenExpireDate: Date {
        get {
            return UserDefaults.standard.object(forKey: PreferencesKeys.tokenExpireDate) as? Date ?? Date.distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PreferencesKeys.tokenExpireDate)
        }
    }
    
    static var isTokenExpired: Bool {
        return Date().timeIntervalSince(tokenExpireDate) > 0.0
    }
    
    static var apiScope: String? {
        get {
            return UserDefaults.standard.string(forKey: PreferencesKeys.apiScope)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: PreferencesKeys.apiScope)
        }
    }
    
}
