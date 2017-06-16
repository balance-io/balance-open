//
//  Singletons.swift
//  Bal
//
//  Created by Benjamin Baron on 6/20/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import XCGLogger

let keychain = KeychainManagerFactory()
let database = Database()
let log = XCGLogger.default
let logging = Logging()
let syncManager = SyncManager()
let defaults = Defaults()
let appLock = AppLock()
let networkStatus = NetworkStatus()
let certValidator = CertValidator()
let serverMessage = ServerMessage()

func initializeSingletons() {
    _ = keychain
    _ = database
    _ = log
    _ = logging
    _ = syncManager
    _ = defaults
    _ = appLock
    _ = networkStatus
    _ = autoLaunch
}
