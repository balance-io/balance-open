//
//  AnalyticsWrapper.swift
//  Balance
//
//  Created by Raimon Lapuente Ferran on 10/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

class AnalyticsWrapper {
    
    static func setAnalytics() {
        #if PLATFORM_MACOS
        #if !DEBUG
            BITHockeyManager.shared().configure(withIdentifier: "bca73ad39bdb4dda98870be89899e263")
            BITHockeyManager.shared().start()
        #endif
        #endif
        
        #if !DEBUG
            BITHockeyManager.shared().configure(withIdentifier: "dd541e76abab4023ab1e045e21a4d60d")
            BITHockeyManager.shared().start()
        #endif
    }
    
    static func trackEvent(withName: String) {
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: withName)
    }
    
    static func trackEvent(withName: String, info: [String:String]) {
        BITHockeyManager.shared()?.metricsManager?.trackEvent(withName: withName, properties: info, measurements: nil)
    }
}
