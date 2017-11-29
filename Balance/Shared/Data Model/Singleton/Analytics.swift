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
        Countly.sharedInstance().recordEvent(withName, segmentation:info)
    }
}
