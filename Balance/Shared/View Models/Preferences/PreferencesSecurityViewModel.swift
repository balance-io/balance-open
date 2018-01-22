//
//  PreferencesSecurityViewModel.swift
//  BalancemacOS
//
//  Created by Eli Pacheco Hoyos on 1/18/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

protocol AppLockServicesProtocol {
    var lockAfterMinutes: Bool { get }
    var lockInterval: TimeInterval? { get }
    func lock(until timeInterval: TimeInterval?)
}

protocol TimeServicesProtocol {
    var currentTime: Date? { get }
    var timeIntervals: [String] { get }
}

extension TimeServicesProtocol {
    
    var intervals: [String: TimeInterval] {
        return [
            "15 Minutes" : TimeInterval.minute * Double(15),
            "30 Minutes" : TimeInterval.minute * Double(30),
            "45 Minutes" : TimeInterval.minute * Double(45),
            "50 Minutes" : TimeInterval.minute * Double(50),
            "1 Hour" : TimeInterval.hour,
            "2 Hour" : TimeInterval.hour * Double(2),
            "3 Hour" : TimeInterval.hour * Double(3),
            "5 Hour" : TimeInterval.hour * Double(5),
            "8 Hour" : TimeInterval.hour * Double(8),
            "1 Day" : TimeInterval.day
        ]
    }
    
}

class TimeServices: TimeServicesProtocol {

    var currentTime: Date? {
        return Date()
    }
    
    var timeIntervals: [String] {
        return intervals.sortedByValue.map { $0.0 }
    }
    
    var lockInterval: TimeInterval? {
        return appLock.lockInterval
    }
    
    var lockAfterMinutes: Bool {
        return appLock.lockAfterMinutes
    }
    
    func lock(until timeInterval: TimeInterval?) {
        appLock.lock(until: timeInterval)
    }
    
}

class PreferencesSecurityViewModel {
    
    let timeServices: TimeServicesProtocol
    let appLockServices: AppLockServicesProtocol
    
    var timeIntervals: [String] {
        return timeServices.timeIntervals
    }
    
    var currentTimeInterval: String {
        return timeIntervals[selectedTimeInterval]
    }
    
    var isLockAfterMinutesSelected: Bool {
        return appLockServices.lockAfterMinutes
    }
    
    var selectedTimeInterval: Int {
        guard let lockInterval = appLockServices.lockInterval else {
            return 0
        }
        
        for (index, intervalKey) in timeIntervals.enumerated() {
            if timeServices.intervals[intervalKey] == lockInterval {
                return index
            }
        }
        
        return 0
    }
    
    init(timeServices: TimeServicesProtocol? = nil, appLockServices: AppLockServicesProtocol? = nil) {
        self.timeServices = timeServices ?? TimeServices()
        self.appLockServices = appLockServices ?? appLock
    }
    
    func selectTimeInterval(at index: Int) {
        guard let selectedInterval = timeIntervals[safe: index],
            let timeInterval = timeServices.intervals[selectedInterval] else {
                print("Cant create interval for selected option")
                return
        }
        
        appLockServices.lock(until: timeInterval)
    }
    
    func removeSkipBlock() {
        appLockServices.lock(until: nil)
    }
    
}
