//
//  Analytics.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 10/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class Analytics {
    func setupAnalytics() {
        #if !DEBUG
            #if os(OSX)
                let identifier = "bca73ad39bdb4dda98870be89899e263"
            #else
                let identifier = "dd541e76abab4023ab1e045e21a4d60d"
            #endif
            
            guard let hockeyManager = BITHockeyManager.shared() else {
                log.error("Failed to start BITHockeyManager because it was nil")
                return
            }
            hockeyManager.configure(withIdentifier: identifier)
            hockeyManager.start()
        #endif
        setupCountly()
    }
    
    func setupCountly() {
        let config: CountlyConfig = CountlyConfig()
        config.appKey = "1807f895bbaa63752af11bc3f4ff6d4983f2e916"
        config.features = ["CLYCrashReporting"]
        config.host = "https://try.count.ly"
        Countly.sharedInstance().start(with: config)
        
        #if DEBUG
        config.enableDebug = true
        #endif
    }
    
    func trackEvent(withName: String, info: [String:String]? = nil) {
        #if !DEBUG
        BITHockeyManager.shared().metricsManager.trackEvent(withName: withName, properties: info, measurements: nil)
        #endif
        Countly.sharedInstance().recordEvent(withName, segmentation:info)
    }
}
