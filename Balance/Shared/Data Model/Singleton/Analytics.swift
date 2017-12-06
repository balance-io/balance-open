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
        #if RELEASE
            setupCountly()
        #endif
    }
    
    func setupCountly() {
        let config: CountlyConfig = CountlyConfig()
        #if os(OSX)
            config.appKey = "1081ada3bebaec706d02253579237e8c243e6b29"
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
}
