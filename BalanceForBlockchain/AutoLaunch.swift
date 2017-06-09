//
//  AutoLaunch.swift
//  Bal
//
//  Created by Benjamin Baron on 7/29/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import AppKit
import ServiceManagement

class AutoLaunch {
    fileprivate let helperAppId = "software.balanced.BalanceForBlockchain-helper"
    fileprivate let queryHelperNotification = Notification.Name(rawValue: "queryHelperNotification")
    fileprivate let queryHelperResponseNotification = Notification.Name(rawValue: "queryHelperResponseNotification")
    
    var wasLaunchedAtLogin = false
    
    func launchAtLogin(_ enabled: Bool) -> Bool {
        return SMLoginItemSetEnabled(helperAppId as CFString, enabled)
    }
    
    // Query the helper app to reply with the time it launched Balance
    func queryHelper() {
        Swift.print("Balance sending message to helper app")
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(queryResponse), name: queryHelperResponseNotification, object: nil)
        DistributedNotificationCenter.default().postNotificationName(queryHelperNotification, object: nil, deliverImmediately: true)
    }
    
    // Due to shitty sandboxing restrictions, we cannot receive userInfo, so if we get a reply at all
    // then we'll assume we were launched by the helper
    @objc fileprivate func queryResponse() {
        wasLaunchedAtLogin = true
        DistributedNotificationCenter.default().removeObserver(self, name: queryHelperResponseNotification, object: nil)
        Swift.print("Balance received reply")
    }
}
