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
        #if os(OSX)
            config.appKey = "1081ada3bebaec706d02253579237e8c243e6b29"
        #else
            config.appKey = "dcf554028cf742764b85e5c0b7b2ccb6dbafa156"
        #endif
        config.features = ["CLYCrashReporting"]
        config.host = "http://countly.balancemy.money"
        Countly.sharedInstance().start(with: config)
        
        #if DEBUG
        config.enableDebug = true
        #endif
    }
    
    func trackEvent(withName: String, info: [String:String]? = nil) {
        Countly.sharedInstance().recordEvent(withName, segmentation:info)
    }
}
