//
//  SyncDefaults.swift
//  Bal
//
//  Created by Benjamin Baron on 2/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

#if os(OSX)
import Foundation
#else
import UIKit
#endif

class SyncDefaults {
    fileprivate struct Keys {
        static let lastSyncTimeKey = "lastSyncTime"
        static let lastSuccessfulSyncTimeKey = "lastSuccessfulSyncTime"
    }
    
    fileprivate let userDefaults = UserDefaults.standard
    
    // Sync every minute while visible
    fileprivate let activeSyncInterval = 60.0
    // Regularly sync every 30 minutes
    fileprivate let inactiveSyncInterval = 60.0 * 30.0
    
    var syncInterval: Double {
        #if os(OSX)
            let isActive = AppDelegate.sharedInstance.statusItem.isStatusItemWindowVisible
        #else
            let isActive = (UIApplication.shared.applicationState == .active)
        #endif
        return isActive ? activeSyncInterval : inactiveSyncInterval
    }
    
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
