//
//  Singletons.swift
//  Bal
//
//  Created by Benjamin Baron on 6/20/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import XCGLogger
import RealmSwift

let keychain = Testing.runningTests ? MockedKeychainManagerFactory() : KeychainManagerFactory()
let database = Testing.runningTests ? Testing.database : Database()
let debugging = Debugging()
let log = XCGLogger.default
let logging = Logging()
let feed = Feed()
let insights = Insights()
let syncManager = SyncManager()
let defaults: Defaults = Testing.runningTests ? Testing.defaults : Defaults()
let institutionsDatabase = InstitutionsDatabase()
let appLock = AppLock()
let subscriptionManager = SubscriptionManager()
let realmManager = RealmManager()
let networkStatus = NetworkStatus()
let certValidator = CertValidator()
let serverMessage = ServerMessage()

func initializeSingletons() {
    _ = keychain
    _ = database
    _ = debugging
    _ = log
    _ = logging
    _ = feed
    _ = insights
    _ = syncManager
    _ = defaults
    
    _ = institutionsDatabase
    _ = appLock
    _ = subscriptionManager
    _ = networkStatus
}
