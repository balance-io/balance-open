//
//  Analytics.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 10/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

@objc class Analytics: NSObject {
    func setupAnalytics() {
        #if RELEASE
            setupCountly()
            registerNotifications()
        #endif
    }
    
    func setupCountly() {
        let config: CountlyConfig = CountlyConfig()
        #if os(OSX)
            config.appKey = "1081ada3bebaec706d02253579237e8c243e6b29"
            config.manualSessionHandling = true
        #else
            config.appKey = "dcf554028cf742764b85e5c0b7b2ccb6dbafa156"
        #endif
        config.features = ["CLYCrashReporting"]
        config.host = "https://countly.balancemy.money"
        Countly.sharedInstance().start(with: config)
    }
    
    func trackEvent(withName: String, info: [String:String]? = nil) {
        #if RELEASE
            Countly.sharedInstance().recordEvent(withName, segmentation:info)
        #endif
    }
    
    // MARK: - macOS Manual Session Management -
    
    deinit {
        unregisterNotifications()
    }
    
    func registerNotifications() {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(beginSession), name: Notifications.PopoverWillShow)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(endSession), name: Notifications.PopoverWillHide)
    }
    
    func unregisterNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: Notifications.PopoverWillShow)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(endSession), name: Notifications.PopoverWillHide)
    }
    
    @objc func beginSession() {
        log.debug("beginSession")
        Countly.sharedInstance().beginSession()
        startAutomaticallyUpdatingSession()
    }
    
    func startAutomaticallyUpdatingSession() {
        assert(Thread.isMainThread, "Must call startAutomaticallyUpdatingSession from main thread")
        stopAutomaticallyUpdatingSession()
        self.perform(#selector(updateSession), with: nil, afterDelay: 60.0)
    }
    
    func stopAutomaticallyUpdatingSession() {
        assert(Thread.isMainThread, "Must call stopAutomaticallyUpdatingSession from main thread")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateSession), object: nil)
    }
    
    // Automatically update session every 60 seconds while active
    @objc func updateSession() {
        log.debug("updateSession")
        Countly.sharedInstance().updateSession()
    }
    
    @objc func endSession() {
        log.debug("endSession")
        stopAutomaticallyUpdatingSession()
        Countly.sharedInstance().endSession()
    }
}
