//
//  TimeInterval.swift
//  Bal
//
//  Created by Benjamin Baron on 11/10/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

extension TimeInterval {
    static var second: TimeInterval { return 1.0 }
    
    static var minute: TimeInterval { return 60.0 }
    
    static var hour: TimeInterval { return minute * 60.0 }
    
    static var day: TimeInterval { return hour * 24.0 }
    
    static var month: TimeInterval { return day * 30.0 }
    
    static var year: TimeInterval { return month * 12.0 }
}
