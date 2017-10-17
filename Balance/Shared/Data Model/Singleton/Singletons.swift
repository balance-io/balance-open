//
//  Singletons.swift
//  Bal
//
//  Created by Benjamin Baron on 6/20/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import XCGLogger

let keychain = Testing.runningTests ? MockedKeychainManagerFactory() : KeychainManagerFactory()
let database = Testing.runningTests ? Testing.database : Database()
let debugging = Debugging()
let log = XCGLogger.default
let logging = Logging()
let currentExchangeRates = CurrentExchangeRates()
let syncManager = SyncManager()
let defaults: Defaults = Testing.runningTests ? Testing.defaults : Defaults()
let appLock = AppLock()
let networkStatus = NetworkStatus()
let certValidator = CertValidator()
let certValidatedSession = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
let serverMessage = ServerMessage()

func initializeSingletons() {
    _ = keychain
    _ = database
    _ = debugging
    _ = log
    _ = logging
    _ = currentExchangeRates
    _ = syncManager
    _ = defaults
    
    _ = appLock
    _ = networkStatus
}
