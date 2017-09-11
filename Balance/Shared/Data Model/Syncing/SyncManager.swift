//
//  SyncManager.swift
//  Bal
//
//  Created by Benjamin Baron on 4/8/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class SyncManager: NSObject {
    
    let syncDefaults = SyncDefaults()
    var hasSyncedSinceLaunch = false // Ensure we always sync on launch
    
    fileprivate let oneMonth: TimeInterval = 60 * 60 * 24 * 31
    fileprivate let tenYears: TimeInterval = 60 * 60 * 24 * 365 * 10
    
    var syncing: Bool {
        return syncer.syncing
    }
    
    var canceled: Bool {
        return syncer.canceled
    }
    
    fileprivate var syncer = debugging.useMockSyncing ? MockSyncer() : Syncer()
    
    override init() {
        super.init()
        
        #if os(OSX)
        // Register for wake notification
        async {
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.syncIfGreaterThanSyncInterval), name: NSWorkspace.didWakeNotification, object: nil)
        }
        #else
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncIfGreaterThanSyncInterval), name: .UIApplicationDidBecomeActive)
        #endif
        
        // Network status notifications
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(syncIfGreaterThanSyncInterval), name: Notifications.NetworkBecameReachable)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(cancel), name: Notifications.NetworkBecameUnreachable)
    }
    
    deinit {
        #if os(OSX)
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.didWakeNotification, object: nil)
        #else
        NotificationCenter.removeObserverOnMainThread(self, name: .UIApplicationDidBecomeActive)
        #endif

        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.NetworkBecameReachable)
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.NetworkBecameUnreachable)
    }
    
    @objc func cancel() {
        guard syncer.syncing else {
            return
        }
        
        syncer.cancel()
    }
    
    @objc func automaticSync() {
        sync(userInitiated: false, validateReceipt: true, completion: nil)
    }
    
    @objc func syncIfGreaterThanSyncInterval() {        
        let lastSync = syncDefaults.lastSuccessfulSyncTime
        let performSync = !hasSyncedSinceLaunch || Date().timeIntervalSince(lastSync) > syncDefaults.syncInterval
        if performSync {
            sync(completion: nil)
        }
    }
    
    func sync(userInitiated: Bool = false, validateReceipt: Bool = true, completion: SuccessErrorsHandler? = nil) {
        guard !syncer.syncing && networkStatus.isReachable && Thread.isMainThread else {
            completion?(true, [])
            return
        }
        
        // Make sure institutions are in sync before syncing
        institutionsDatabase.checkForUpdate {
            if validateReceipt {
                // First validate receipt and sync access tokens
                subscriptionManager.validateReceipt { code, _, accessTokens in
                    if code == .success {
                        if let accessTokens = accessTokens {
                            self.syncAccessTokens(accessTokens)
                        }
                        self.performSync(userInitiated: userInitiated, completion: completion)
                    }
                }
            } else {
                self.performSync(userInitiated: userInitiated, completion: completion)
            }
        }
    }
    
    func syncAccessTokens(_ accessTokens: [String: String]) {
        let institutionsCount = InstitutionRepository.si.institutionsCount
        
        // Purge any orphaned local institutions
        let localInstitutions = InstitutionRepository.si.allInstitutions()
        for institution in localInstitutions {
            if let token = institution.accessToken, !accessTokens.keys.contains(token) {
                log.debug("Removing \(institution.sourceInstitutionId) because it was removed server-side")
                
                // This access token is not registered with the server, so delete the institution
                institution.delete()
            }
        }
        
        // Add any new access tokens
        // TODO: Generalize this to different data sources
        var tokensAdded = 0
        let localTokens: [String] = InstitutionRepository.si.allInstitutions().flatMap({$0.accessToken})
        for remoteToken in accessTokens.keys {
            if !localTokens.contains(remoteToken) {
                tokensAdded += 1
                // This institution doesn't exist, so add it
                if let sourceInstitutionId = accessTokens[remoteToken], let plaidInstitution = institutionsDatabase.search(source: .plaid, sourceInstitutionId: sourceInstitutionId) {
                    _ = InstitutionRepository.si.institution(source: .plaid, sourceInstitutionId: plaidInstitution.sourceInstitutionId, name: plaidInstitution.name, accessToken: remoteToken)
                    log.debug("Created plaid institution with sourceInstitutionId: \(plaidInstitution.institutionId)")
                } else {
                    log.error("Somehow couldn't find the plaid institution in the database, deleting token from server")
                    subscriptionManager.plaidDeleteAccessToken(accessToken: remoteToken)
                }
            }
        }
        
        log.debug("Added \(tokensAdded) new tokens")
        
        if institutionsCount == 0 && tokensAdded > 0 {
            NotificationCenter.postOnMainThread(name: Notifications.ShowTabs)
        }
    }
    
    fileprivate func performSync(userInitiated: Bool = false, completion: SuccessErrorsHandler? = nil) {
        // Cancel any automatic runs of this method in case it's called manually
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.automaticSync), object: nil)
       
        hasSyncedSinceLaunch = true
        
        hasSyncedSinceLaunch = true
        
        // Determine whether to do a full sync or not
        // Current algorithm is full sync (10 years) every 24 hours, partial sync (1 month) every hour
        let lastFullSync = syncDefaults.lastSuccessfulFullSyncTime
        let newInstitutionsOnly = !userInitiated && Date().timeIntervalSince(syncDefaults.lastSyncTime) < syncDefaults.normalSyncInterval
        let performFullSync = newInstitutionsOnly || Date().timeIntervalSince(lastFullSync) > syncDefaults.fullSyncInterval
        let startDate = performFullSync ? Date(timeIntervalSinceNow: -tenYears) : Date(timeIntervalSinceNow: -oneMonth)
        log.debug(newInstitutionsOnly ? "Syncing new institutions only" : "Syncing all institutions")
        log.debug(performFullSync ? "Performing full sync" : "Performing partial sync")
        
        // Start the sync
        self.syncer = debugging.useMockSyncing ? MockSyncer() : Syncer()
        self.syncer.sync(newInstitutionsOnly: newInstitutionsOnly, startDate: startDate, pruneTransactions: performFullSync) { success, errors in
            // Set the last sync dates, record all syncs using the lastSyncTime keys for ease of use then record full syncs separately
            let now = Date()
            self.syncDefaults.lastSyncTime = now
            if success {
                self.syncDefaults.lastSuccessfulSyncTime = now
            }
            
            if performFullSync {
                self.syncDefaults.lastFullSyncTime = now
                if success {
                    self.syncDefaults.lastSuccessfulFullSyncTime = now
                }
            }
            
            // Notifications (perform regardless of success because some institutions could have succeeded)
            if self.syncDefaults.lastSyncMaxTransactionId > 0 {
                // Update unread notifications count
                let existingUnreadTransactionIds = Set<Int>(defaults.unreadNotificationIds)
                let newUnreadTransactionIds = feed.unreadTransactionIds(sinceTransactionId: self.syncDefaults.lastSyncMaxTransactionId)
                let unreadTransactionIds = existingUnreadTransactionIds.union(newUnreadTransactionIds)
                defaults.unreadNotificationIds = unreadTransactionIds
                
                // Notify the user about these transactions
                let notifyTransactions = feed.allNotifyTransactions(sinceTransactionId: self.syncDefaults.lastSyncMaxTransactionId)
                feed.sendTransactionNotifications(transactions: notifyTransactions)
            }
            self.syncDefaults.lastSyncMaxTransactionId = TransactionRepository.si.maxTransactionId
            
            // Notify observers
            NotificationCenter.postOnMainThread(name: Notifications.SyncCompleted)
            
            // Always run every sync interval. If we were manually run, this will reset the sync interval.
            self.perform(#selector(self.automaticSync), with: nil, afterDelay: self.syncDefaults.syncInterval)
            
            // Call the originally passed completion block if it exists
            completion?(success, errors)
        }
    }
}
