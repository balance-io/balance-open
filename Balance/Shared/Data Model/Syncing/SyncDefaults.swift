//
//  SyncDefaults.swift
//  Bal
//
//  Created by Benjamin Baron on 2/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class SyncDefaults {
    fileprivate struct Keys {
        static let lastSyncTimeKey = "lastSyncTime"
        static let lastSuccessfulSyncTimeKey = "lastSuccessfulSyncTime"
    }
    
    fileprivate let userDefaults = UserDefaults.standard
    
    // Regularly sync every 20 minutes
    var syncInterval = 20.0 * 60.0
    
    var lastSyncTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastSyncTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastSyncTimeKey)
        }
    }
    
    var lastSuccessfulSyncTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastSuccessfulSyncTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastSuccessfulSyncTimeKey)
        }
    }
}
