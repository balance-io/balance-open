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
        static let lastFullSyncTimeKey = "lastFullSyncTime"
        static let lastSuccessfulSyncTimeKey = "lastSuccessfulSyncTime"
        static let lastSuccessfulFullSyncTimeKey = "lastSuccessfulFullSyncTime"
        static let lastSyncMaxTransactionIdKey = "lastSyncMaxTransactionId"
        static let lastNewInstitutionAddedTimeKey = "lastNewInstitutionAddedTimeKey"
    }
    
    fileprivate let userDefaults = UserDefaults.standard
    
    // Regularly sync once per hour
    let normalSyncInterval: TimeInterval = 60.0 * 60.0
    
    var syncInterval: TimeInterval {
        let intervalSinceLastNewInstitution = Date().timeIntervalSince(lastNewInstitutionAddedTime)
        if intervalSinceLastNewInstitution <= 60 * 2 {
            // First 2 minutes, sync every 30 seconds
            return 30
        } else if intervalSinceLastNewInstitution <= 60 * 5 {
            // Next 3 minutes, sync every minute
            return 60
        } else if intervalSinceLastNewInstitution < 60 * 60 {
            // For the rest of the hour, sync every 20 minutes
            return 60 * 20
        } else {
            // Normal sync interval
            return normalSyncInterval
        }
    }
    
    var fullSyncInterval: TimeInterval {
        let intervalSinceLastNewInstitution = Date().timeIntervalSince(lastNewInstitutionAddedTime)
        if intervalSinceLastNewInstitution <= 60 * 120 {
            // If we've recently added an institution, always do a full sync
            return 0
        } else {
            // Regularly perform a full sync once per day
            return 60 * 60 * 24
        }
    }
    
    var lastSyncTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastSyncTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastSyncTimeKey)
        }
    }
    
    var lastFullSyncTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastFullSyncTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastFullSyncTimeKey)
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
    
    var lastSuccessfulFullSyncTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastSuccessfulFullSyncTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastSuccessfulFullSyncTimeKey)
        }
    }
    
    var lastSyncMaxTransactionId: Int {
        get {
            return userDefaults.integer(forKey: Keys.lastSyncMaxTransactionIdKey)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastSyncMaxTransactionIdKey)
        }
    }
    
    var lastNewInstitutionAddedTime: Date {
        get {
            return userDefaults.object(forKey: Keys.lastNewInstitutionAddedTimeKey) as? Date ?? Date.distantPast
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastNewInstitutionAddedTimeKey)
            
            // Schedule the next sync using the shorter syncInterval
            async {
                if !syncManager.syncing {
                    NSObject.cancelPreviousPerformRequests(withTarget: syncManager, selector: #selector(SyncManager.automaticSync), object: nil)
                    syncManager.perform(#selector(SyncManager.automaticSync), with: nil, afterDelay: self.syncInterval)
                }
            }
        }
    }
}
