//
//  PreferencesSecurityViewModel.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/18/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

class PreferencesSecurityViewModel: NSObject {
    
    let timeIntervals = ["15 minutes", "30 minutes", "1 Hour", "2 Hour", "3 Hour"]
    
    var currentTimeInterval: String {
        return timeIntervals[selectedTimeInterval]
    }
    
    var selectedTimeInterval: Int {
        return 0
    }
    
}
