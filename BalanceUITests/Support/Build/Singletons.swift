//
//  Singletons.swift
//  Bal
//
//  Created by Jamie Rumbelow on 8/23/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import XCGLogger

let database = Database()
let debugging = Debugging()
let log = XCGLogger.defaultInstance()
let logging = Logging()
let feed = Feed()
let insights = Insights()
let plaidApi = PlaidApi()
let syncManager = SyncManager()
let defaults = Defaults()
let autoLaunch = AutoLaunch()
